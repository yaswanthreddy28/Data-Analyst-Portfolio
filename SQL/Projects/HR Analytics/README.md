🧑‍💼 HR Analytics with SQL (PostgreSQL)

Author: Yaswanth Reddy
Role Focus: Data Analyst / Business Analyst
Tech Stack: PostgreSQL, SQL
Level: Strong Intermediate → Advanced Analytics SQL

📌 Project Overview

This project is an end-to-end HR Analytics case study built entirely in SQL, focusing on real business decision-making, not just query writing.

The goal of this project is to demonstrate:

How analysts translate business questions into SQL

How to design clean, explainable queries

How to use advanced SQL constructs responsibly

How to avoid overengineering while still being realistic

This project is intentionally lightweight but deep — optimized for interviews and portfolio reviews.

🧠 What This Project Is (and Is Not)
✅ What it IS

Business-driven HR analytics

Interview-safe SQL complexity

Clean schema with managerial hierarchy

Strong use of CTEs and window functions

Queries you can explain under pressure

❌ What it is NOT

A toy dataset

An overcomplicated enterprise warehouse

A JOIN-heavy monster that takes minutes to reason about

🧱 Database Scope

The database models a realistic HR system with:

Employees (with manager relationships)

Departments

Roles & seniority levels

Salary history

Performance reviews

This enables analysis across:

Compensation & pay equity

Performance vs pay

Hiring & growth trends

Org structure & leadership depth

Department-level ROI

📂 Repository Structure
├── 01_HR_Analytics_Business_Insights.sql
├── 02_Core_HR_SQL_Foundations.sql
├── 03_Advanced_Analytics_Window_Functions.sql


Each file represents a clear skill layer, progressing from fundamentals to business impact.

📊 01_HR_Analytics_Business_Insights.sql
🔹 Business-Focused Analytics (Primary Portfolio File)

This file answers real HR leadership questions, such as:

🔥 High-potential employees at attrition risk

👥 Managerial span of control

⚖️ Gender pay gap analysis

💰 Departmental ROI (performance per salary dollar)

🚨 Overpaid / underperforming talent

📈 Hiring trends and workforce concentration

🏢 Executive bench strength

📋 Department “Value” summary reports

Skills Demonstrated

Translating ambiguous business problems into SQL

Choosing the right aggregation level (data grain)

Window functions for ranking and comparisons

Thoughtful use of CTEs for readability

Business-first naming and logic

📌 This is the main file recruiters should review first.

🧠 02_Core_HR_SQL_Foundations.sql
🔹 SQL Fundamentals Done Right

This file demonstrates strong analytical SQL foundations, including:

INNER, LEFT, and self-joins

GROUP BY with correct aggregations

CASE statements for business logic

Subqueries vs CTEs (with reasoning)

NULL-safe logic and assumptions

Readable, maintainable query structure

Why this matters

Recruiters care less about how complex your SQL is, and more about:

Can you reason about joins?

Can you avoid double counting?

Can you explain your logic clearly?

This file answers all three.

🧮 03_Advanced_Analytics_Window_Functions.sql
🔹 Advanced SQL for Analytics

This file focuses on window functions used in real analytics workflows, including:

ROW_NUMBER, RANK, DENSE_RANK

NTILE for salary banding

Department vs company-wide comparisons

Running totals and cumulative metrics

Percent contribution to department budgets
