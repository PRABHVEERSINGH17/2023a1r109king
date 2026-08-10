const API_BASE = "";

const messagesEl = document.getElementById("messages");
const chatForm = document.getElementById("chat-form");
const messageInput = document.getElementById("message-input");
const sendBtn = document.getElementById("send-btn");
const suggestionChips = document.getElementById("suggestion-chips");
const categoryList = document.getElementById("category-list");
const quickQuestions = document.getElementById("quick-questions");
const collegeNameEl = document.getElementById("college-name");
const clearChatBtn = document.getElementById("clear-chat");
const menuToggle = document.getElementById("menu-toggle");
const sidebar = document.getElementById("sidebar");
const sidebarOverlay = document.getElementById("sidebar-overlay");

let isLoading = false;

function closeSidebar() {
  sidebar?.classList.remove("open");
  sidebarOverlay?.classList.remove("visible");
}

menuToggle?.addEventListener("click", () => {
  sidebar?.classList.toggle("open");
  sidebarOverlay?.classList.toggle("visible");
});

sidebarOverlay?.addEventListener("click", closeSidebar);

async function init() {
  try {
    const res = await fetch(`${API_BASE}/api/college`);
    const data = await res.json();
    collegeNameEl.textContent = data.college_name;

    renderCategories(data.categories);
    renderQuickQuestions(data.categories);
  } catch (err) {
    console.error("Failed to load college info:", err);
  }
}

function renderCategories(categories) {
  categoryList.innerHTML = "";
  categories.forEach((cat) => {
    const btn = document.createElement("button");
    btn.className = "category-btn";
    btn.innerHTML = `${cat.icon} ${cat.name}`;
    btn.addEventListener("click", () => {
      document.querySelectorAll(".category-btn").forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      closeSidebar();
      if (cat.faqs.length > 0) {
        sendMessage(cat.faqs[0].question, false);
      }
    });
    categoryList.appendChild(btn);
  });
}

function renderQuickQuestions(categories) {
  quickQuestions.innerHTML = "";
  const allFaqs = categories.flatMap((c) => c.faqs).slice(0, 6);
  allFaqs.forEach((faq) => {
    const btn = document.createElement("button");
    btn.className = "quick-btn";
    btn.textContent = faq.question;
    btn.addEventListener("click", () => {
      closeSidebar();
      sendMessage(faq.question, false);
    });
    quickQuestions.appendChild(btn);
  });
}

function appendMessage(text, role, meta = null) {
  const div = document.createElement("div");
  div.className = `message ${role}`;

  const avatar = document.createElement("div");
  avatar.className = "avatar";
  avatar.textContent = role === "user" ? "👤" : "🤖";

  const bubble = document.createElement("div");
  bubble.className = "bubble";
  const p = document.createElement("p");
  p.textContent = text;
  bubble.appendChild(p);

  if (meta) {
    const metaEl = document.createElement("div");
    metaEl.className = "meta";
    if (meta.matched_question) {
      const q = document.createElement("span");
      q.textContent = `Matched: ${meta.matched_question}`;
      metaEl.appendChild(q);
    }
    if (meta.category) {
      const c = document.createElement("span");
      c.textContent = `Category: ${meta.category}`;
      metaEl.appendChild(c);
    }
    if (meta.confidence > 0) {
      const conf = document.createElement("span");
      const pct = Math.round(meta.confidence * 100);
      conf.textContent = `Confidence: ${pct}%`;
      conf.className =
        pct >= 50 ? "confidence-high" : pct >= 30 ? "confidence-mid" : "confidence-low";
      metaEl.appendChild(conf);
    }
    bubble.appendChild(metaEl);
  }

  div.appendChild(avatar);
  div.appendChild(bubble);
  messagesEl.appendChild(div);
  messagesEl.scrollTop = messagesEl.scrollHeight;
}

function showTyping() {
  const div = document.createElement("div");
  div.className = "message bot typing";
  div.id = "typing-indicator";
  div.innerHTML = `
    <div class="avatar">🤖</div>
    <div class="bubble"><span></span><span></span><span></span></div>
  `;
  messagesEl.appendChild(div);
  messagesEl.scrollTop = messagesEl.scrollHeight;
}

function hideTyping() {
  const el = document.getElementById("typing-indicator");
  if (el) el.remove();
}

function renderSuggestions(suggestions) {
  suggestionChips.innerHTML = "";
  if (!suggestions || suggestions.length === 0) return;

  suggestions.forEach((q) => {
    const chip = document.createElement("button");
    chip.className = "chip";
    chip.textContent = q;
    chip.type = "button";
    chip.addEventListener("click", () => sendMessage(q, false));
    suggestionChips.appendChild(chip);
  });
}

async function sendMessage(text, showUserBubble = true) {
  if (isLoading || !text.trim()) return;

  isLoading = true;
  sendBtn.disabled = true;
  suggestionChips.innerHTML = "";

  if (showUserBubble) {
    appendMessage(text.trim(), "user");
  } else {
    appendMessage(text.trim(), "user");
  }

  messageInput.value = "";
  showTyping();

  try {
    const res = await fetch(`${API_BASE}/api/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: text.trim() }),
    });

    if (!res.ok) throw new Error("Chat request failed");

    const data = await res.json();
    hideTyping();
    appendMessage(data.answer, "bot", data);
    renderSuggestions(data.suggestions);
  } catch (err) {
    hideTyping();
    appendMessage(
      "Sorry, something went wrong. Please make sure the server is running and try again.",
      "bot"
    );
    console.error(err);
  } finally {
    isLoading = false;
    sendBtn.disabled = false;
    messageInput.focus();
  }
}

chatForm.addEventListener("submit", (e) => {
  e.preventDefault();
  sendMessage(messageInput.value);
});

clearChatBtn.addEventListener("click", () => {
  messagesEl.innerHTML = `
    <div class="message bot">
      <div class="avatar">🤖</div>
      <div class="bubble">
        <p>Chat cleared. How can I help you today?</p>
      </div>
    </div>
  `;
  suggestionChips.innerHTML = "";
});

messageInput.addEventListener("keydown", (e) => {
  if (e.key === "Enter" && !e.shiftKey) {
    e.preventDefault();
    chatForm.dispatchEvent(new Event("submit"));
  }
});

init();
