import os
import boto3
from flask import Flask, request, redirect, url_for, render_template
from werkzeug.utils import secure_filename

app = Flask(__name__)
s3 = boto3.client('s3')

BUCKET_NAME = os.getenv('S3_BUCKET_NAME')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return redirect(url_for('index'))

    file = request.files['file']
    if file.filename == '':
        return redirect(url_for('index'))

    if file:
        filename = secure_filename(file.filename)
        s3.upload_fileobj(file, BUCKET_NAME, filename)
        return redirect(url_for('files'))

@app.route('/files')
def files():
    response = s3.list_objects_v2(Bucket=BUCKET_NAME)
    files = [obj['Key'] for obj in response.get('Contents', [])]
    return render_template('files.html', files=files)

@app.route('/download/<filename>')
def download_file(filename):
    file_obj = s3.get_object(Bucket=BUCKET_NAME, Key=filename)
    return file_obj['Body'].read()

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)