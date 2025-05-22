import oss2
from flask import Flask, request, jsonify
from flask_cors import CORS # Import CORS

app = Flask(__name__)
CORS(app) # Enable CORS for all origins

# Initialize OSS client
def get_oss_bucket(bucket_name):
    access_key_id = 'LTAI5tFcvJZMGSU3iSxot2e6'
    access_key_secret = 'BtaF8CHW6amsTB8YSix5YulTTDDSVs'
    endpoint = 'oss-ap-southeast-1.aliyuncs.com'

    if not all([access_key_id, access_key_secret, endpoint]):
        raise ValueError("OSS environment variables (OSS_ACCESS_KEY_ID, OSS_ACCESS_KEY_SECRET, OSS_ENDPOINT) must be set.")

    auth = oss2.Auth(access_key_id, access_key_secret)
    bucket = oss2.Bucket(auth, endpoint, bucket_name)
    return bucket

@app.route('/fetch_image_keys', methods=['POST'])
def fetch_image_keys():
    try:
        data = request.json
        bucket_name = data.get('bucket_name')
        directory_path = data.get('directory_path')

        if not bucket_name or not directory_path:
            return jsonify({'error': 'bucket_name and directory_path are required'}), 400

        # Ensure the directory path ends with a '/'
        if not directory_path.endswith('/'):
            directory_path += '/'

        bucket = get_oss_bucket(bucket_name)

        image_keys = []
        for obj in oss2.ObjectIterator(bucket, prefix=directory_path):
            if obj.key.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp')):
                image_keys.append(obj.key)

        return jsonify({'image_keys': image_keys}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/download_file', methods=['POST'])
def download_file():
    try:
        data = request.json
        bucket_name = data.get('bucket_name')
        object_key = data.get('object_key')
        local_path = data.get('local_path')

        if not all([bucket_name, object_key, local_path]):
            return jsonify({'error': 'bucket_name, object_key, and local_path are required'}), 400

        bucket = get_oss_bucket(bucket_name)

        bucket.get_object_to_file(object_key, local_path)
        return jsonify({'message': f"File '{object_key}' downloaded to '{local_path}' successfully."}), 200
    except oss2.exceptions.OssError as e:
        return jsonify({'error': f"An OSS error occurred: {str(e)}"}), 500
    except Exception as e:
        return jsonify({'error': f"An unexpected error occurred: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)