(() => {
  const mq = window.matchMedia('(prefers-color-scheme: dark)');
  // One number: OKLab L in 0..1. Invert is 1 - L.
  // Text below 0.35 becomes above 0.65. Backgrounds above 0.65 become below 0.35.
  const BG_L = 0.65;
  const FG_L = 0.35;
  const originals = new WeakMap();
  const touched = [];
  let done = new WeakSet();
  let applying = false;

  function parseAlpha(raw) {
    if (raw == null) return 1;
    const s = String(raw);
    if (s.endsWith('%')) return Number(s.slice(0, -1)) / 100;
    return Number(s);
  }

  function parseRgb(input) {
    if (!input) return null;
    const s = input.trim().toLowerCase();
    if (s === 'transparent' || s === 'none') return null;

    const comma = s.match(
      /^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)(?:\s*,\s*([\d.]+%?))?\s*\)$/
    );
    if (comma) {
      return {
        r: Math.round(Number(comma[1])),
        g: Math.round(Number(comma[2])),
        b: Math.round(Number(comma[3])),
        a: parseAlpha(comma[4]),
      };
    }

    const space = s.match(
      /^rgba?\(\s*([\d.]+)\s+([\d.]+)\s+([\d.]+)(?:\s*\/\s*([\d.]+%?))?\s*\)$/
    );
    if (space) {
      return {
        r: Math.round(Number(space[1])),
        g: Math.round(Number(space[2])),
        b: Math.round(Number(space[3])),
        a: parseAlpha(space[4]),
      };
    }

    return null;
  }

  function srgbToLinear(c) {
    const s = c / 255;
    return s <= 0.04045 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4;
  }

  function linearToSrgb(c) {
    const x = c <= 0.0031308 ? 12.92 * c : 1.055 * c ** (1 / 2.4) - 0.055;
    return Math.round(Math.min(1, Math.max(0, x)) * 255);
  }

  function lab(rgb) {
    const r = srgbToLinear(rgb.r);
    const g = srgbToLinear(rgb.g);
    const b = srgbToLinear(rgb.b);
    const l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
    const m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
    const s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
    return {
      L: 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s,
      a: 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s,
      b: 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s,
    };
  }

  function format(rgb) {
    if (rgb.a === 1) return `rgb(${rgb.r}, ${rgb.g}, ${rgb.b})`;
    return `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${rgb.a})`;
  }

  // Keep hue/chroma (a, b). Only L flips. Shrink chroma if 1-L falls out of sRGB.
  function fromLab(L, a, b, alpha) {
    let lin;
    for (let i = 0; i < 16; i++) {
      const l_ = L + 0.3963377774 * a + 0.2158037573 * b;
      const m_ = L - 0.1055613458 * a - 0.0638541728 * b;
      const s_ = L - 0.0897298708 * a - 1.291485548 * b;
      const l = l_ * l_ * l_;
      const m = m_ * m_ * m_;
      const s = s_ * s_ * s_;
      lin = {
        r: 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        g: -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        b: -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s,
      };
      if (lin.r >= 0 && lin.r <= 1 && lin.g >= 0 && lin.g <= 1 && lin.b >= 0 && lin.b <= 1) break;
      a *= 0.85;
      b *= 0.85;
    }
    return format({
      r: linearToSrgb(lin.r),
      g: linearToSrgb(lin.g),
      b: linearToSrgb(lin.b),
      a: alpha,
    });
  }

  function flip(rgb, prop, el, jobs, should) {
    if (!rgb || rgb.a === 0) return;
    const { L, a, b } = lab(rgb);
    if (!should(L)) return;
    jobs.push([el, prop, fromLab(1 - L, a, b, rgb.a)]);
  }

  function remember(el, prop) {
    let rec = originals.get(el);
    if (!rec) {
      rec = new Map();
      originals.set(el, rec);
      touched.push(el);
    }
    if (!rec.has(prop)) {
      rec.set(prop, {
        value: el.style.getPropertyValue(prop),
        priority: el.style.getPropertyPriority(prop),
      });
    }
  }

  function collect(el, jobs) {
    if (el.nodeType !== 1 || done.has(el)) return;
    const tag = el.tagName;
    if (tag === 'SCRIPT' || tag === 'STYLE' || tag === 'NOSCRIPT' || tag === 'LINK') {
      done.add(el);
      return;
    }

    const cs = getComputedStyle(el);
    flip(parseRgb(cs.getPropertyValue('background-color')), 'background-color', el, jobs, (L) => L > BG_L);
    flip(parseRgb(cs.getPropertyValue('color')), 'color', el, jobs, (L) => L < FG_L);
    done.add(el);

    if (el.shadowRoot) tweak(el.shadowRoot);
  }

  function tweak(root) {
    if (!mq.matches || !root || applying) return;
    const jobs = [];
    if (root.nodeType === 1) collect(root, jobs);
    if (root.querySelectorAll) {
      for (const el of root.querySelectorAll('*')) collect(el, jobs);
    }
    applying = true;
    try {
      for (const [el, prop, next] of jobs) {
        remember(el, prop);
        el.style.setProperty(prop, next, 'important');
      }
    } finally {
      applying = false;
    }
  }

  function revertAll() {
    applying = true;
    try {
      for (const el of touched) {
        const rec = originals.get(el);
        if (!rec) continue;
        for (const [prop, prev] of rec) {
          if (prev.value) el.style.setProperty(prop, prev.value, prev.priority);
          else el.style.removeProperty(prop);
        }
        originals.delete(el);
      }
    } finally {
      applying = false;
      touched.length = 0;
      done = new WeakSet();
    }
  }

  function sync() {
    if (mq.matches) tweak(document.documentElement);
    else revertAll();
  }

  sync();
  mq.addEventListener('change', sync);

  new MutationObserver((records) => {
    if (applying || !mq.matches) return;
    for (const rec of records) {
      for (const node of rec.addedNodes) tweak(node);
    }
  }).observe(document.documentElement, { childList: true, subtree: true });
})();
