const dust = document.getElementById("dust");

if (dust && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
  const count = Math.min(48, Math.floor(window.innerWidth / 28));
  const frag = document.createDocumentFragment();

  for (let i = 0; i < count; i += 1) {
    const mote = document.createElement("span");
    mote.className = "mote";
    mote.style.left = `${Math.random() * 100}%`;
    mote.style.bottom = `${Math.random() * 40}%`;
    mote.style.animationDuration = `${14 + Math.random() * 18}s`;
    mote.style.animationDelay = `${-Math.random() * 20}s`;
    mote.style.opacity = String(0.25 + Math.random() * 0.5);
    frag.append(mote);
  }

  dust.append(frag);
}
