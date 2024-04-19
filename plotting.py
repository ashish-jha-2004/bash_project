import numpy as np
import matplotlib.pyplot as plt
import csv

# Read data from main.csv
with open('main.csv', mode='r') as file:
    reader = csv.DictReader(file)
    data = [row for row in reader]

# Get roll number from user
roll_number = input("Enter Roll Number: ")

# Filter data for student with the given roll number
student_data = [row for row in data if row['Roll_Number'] == roll_number]
if not student_data:
    print("Student not found.")
    exit()

student_data = student_data[0]

# Extract exam marks, interpreting 'a' as 0
exam_marks = []
labels = []
for key, value in student_data.items():
    if key != "Roll_Number" and key != "Name" and key != "Total":
        labels.append(key)
        exam_marks.append(0 if value == 'a' else int(value))

# Calculate highest marks for each subject
highest_marks = []
for key in labels:
    if key != "Total":
        marks = [0 if row[key] == 'a' else int(row[key]) for row in data]
        highest_marks.append(max(marks))

# Plotting the double bar graph
num_exams = len(exam_marks)
x = np.arange(num_exams)
bar_width = 0.35

plt.bar(x, exam_marks, width=bar_width, label='Student Marks')
plt.bar(x + bar_width, highest_marks, width=bar_width, label='Highest Marks')
plt.xticks(x + bar_width / 2, labels)
plt.ylabel('Marks')
plt.title(f'Marks for Student {roll_number} vs Highest Marks')
plt.legend()
plt.show()


# Read data from stats.csv
with open('stats.csv', mode='r') as file:
    reader = csv.DictReader(file)
    data = [row for row in reader]

# Select exam to plot
exam = input("Enter Exam: ")

# Filter data for the selected exam
exam_data = [row for row in data if row['Exam'] == exam][0]

# Extract mean, median, and standard deviation
mean = float(exam_data['Mean'])
median = float(exam_data['Median'])
std_dev = float(exam_data['Standard Deviation'])

# Plotting the bar graph
labels = ['Mean', 'Median', 'Standard Deviation']
values = [mean, median, std_dev]
x = np.arange(len(labels))

plt.bar(x, values)
plt.xticks(x, labels)
plt.ylabel('Marks')
plt.title(f'Stats for {exam}')
plt.show()
