import os

from flask import Flask, render_template, request, redirect
from werkzeug.utils import secure_filename
from s3_functions import list_files, upload_file, show_image

application = Flask(__name__)
UPLOAD_FOLDER = "uploads"
BUCKET = "as-devops-interview-smart-filly"


@application.route("/")
def home():
    contents = list_files(BUCKET)
    return render_template('index.html')


@application.route("/pics")
def list():
    contents = show_image(BUCKET)
    return render_template('collection.html', contents=contents)


@application.route("/upload", methods=['POST'])
def upload():
    if request.method == "POST":
        f = request.files['file']
        f.save(os.path.join(UPLOAD_FOLDER, secure_filename(f.filename)))
        upload_file(f"uploads/{f.filename}", BUCKET)
        return redirect("/")


if __name__ == '__main__':
    application.run(debug=True)
