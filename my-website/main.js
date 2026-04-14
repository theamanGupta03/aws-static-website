// Animate cards on scroll
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry, i) => {
    if (entry.isIntersecting) {
      entry.target.style.animationDelay = `${i * 0.08}s`;
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.15 });

document.querySelectorAll('.card, .flow-step').forEach(el => {
  el.style.opacity = '0';
  el.style.transform = 'translateY(20px)';
  el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
  observer.observe(el);
});

// Trigger animation
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.card, .flow-step').forEach(el => {
    el.addEventListener('animationend', () => {
      el.style.opacity = '';
      el.style.transform = '';
    });
  });
});

// Simple intersection trigger
const scrollObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.style.opacity = '1';
      entry.target.style.transform = 'translateY(0)';
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.card, .flow-step').forEach(el => scrollObserver.observe(el));

// Contact form demo handler
function handleSubmit() {
  const name = document.getElementById('name')?.value.trim();
  const email = document.getElementById('email')?.value.trim();
  const message = document.getElementById('message')?.value.trim();
  const result = document.getElementById('form-result');

  if (!name || !email || !message) {
    result.style.color = '#ff6b6b';
    result.textContent = '⚠️ Please fill in all fields.';
    return;
  }

  result.style.color = '#c8ff57';
  result.textContent = '✅ Demo: Message received! (Wire to API Gateway to make this live.)';

  // In a real setup you'd do:
  // fetch('https://your-domain.com/api/contact', {
  //   method: 'POST',
  //   headers: { 'Content-Type': 'application/json' },
  //   body: JSON.stringify({ name, email, message })
  // });
}
