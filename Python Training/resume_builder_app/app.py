"""
Resume Builder Application

This Flask application provides a web interface for creating and managing resumes.
It includes features for adding personal information, work experience, education,
and skills. The application uses Flask for routing and template rendering.
"""

from flask import Flask, render_template, request

# Initialize Flask application
app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    """
    Render the main page of the resume builder application.
    Returns the index.html template with the initial form.
    If the form is submitted, process the form data and render the resume template.
    """
    if request.method == 'POST':
        # Retrieve form data
        name = request.form.get('name')
        email = request.form.get('email')
        phone = request.form.get('phone')
        education = request.form.get('education')
        experience = request.form.get('experience')
        skills = request.form.get('skills')
        
        # Process the resume data
        resume_data = {
            'name': name,
            'email': email,
            'phone': phone,
            'education': education,
            'experience': experience,
            'skills': skills
        }
        
        # Return the rendered template with the generated resume
        return render_template('resume.html', resume=resume_data)
    # Return the index.html template with the initial form
    return render_template('index.html')

if __name__ == '__main__':
    # Run the application in debug mode when executed directly
    app.run(host='0.0.0.0', port=5000, debug=True)
