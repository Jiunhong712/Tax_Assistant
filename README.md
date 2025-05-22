# Taxly – Expense Tracker & Tax Filing Assistant for Malaysian Freelancers 🇲🇾

**Taxly** is a web application designed to simplify expense tracking and tax filing for Malaysian freelancers. It uses cutting-edge **AI, OCR**, and **cloud technologies** to automate categorization, provide tax relief insights, and guide users through Malaysia’s tax filing system.

---

## 🚀 Features

### 🧾 1. OCR Receipt Scanning
- Uses **GOT OCR 2.0 on Alibaba Cloud PAI** to extract text from receipts and invoices.
- Automatically detects and categorizes expenses/income.

### 🤖 2. AI Categorization & Suggestions
- Powered by **Qwen LLM from Model Studio**.
- Categorizes each transaction based on **official LHDN tax relief categories**.
- Offers suggestions to maximize tax deductions.

### ☁️ 3. Cloud Storage with OSS
- All scanned documents are stored in **Alibaba Cloud OSS**.
- Images are downloadable anytime for personal records.

### 📊 4. Smart Dashboard
- Visualizes expenses by category.
- Provides AI-generated tax-saving insights based on spending patterns.

### 💬 5. Tax Chatbot
- Q&A chatbot trained to answer Malaysia-specific tax queries.
- Guides users through the filing process and explains relief categories.

### 🧮 6. Relief Summary Page
- Displays final categorized values in a format **matching the LHDN e-Filing site**.
- Users can easily copy the values into the government form without confusion.
  

## 📦 Tech Stack

| Category         | Stack/Service                     |
|------------------|-----------------------------------|
| Frontend         | Flutter Web                       |
| OCR              | GOT OCR 2.0 on Alibaba Cloud PAI  |
| AI Categorization| Qwen LLM (Model Studio)           |
| Cloud Storage    | Alibaba Cloud OSS                 |
| Backend          | Flask / OSS API integration       |
| Hosting          | Alibaba Cloud                     |
