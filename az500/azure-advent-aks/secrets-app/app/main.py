from azure.keyvault.secrets import SecretClient
from azure.identity import ManagedIdentityCredential

import os

from flask import Flask
from flask import render_template
from flask import request
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

app = Flask(__name__)

SECRET_KEY = os.urandom(32)
app.config['SECRET_KEY'] = SECRET_KEY

class KVForm(FlaskForm):
    keyVaultName = StringField('Key Vault Name', validators=[DataRequired()])
    secretName = StringField('Secret Name', validators=[DataRequired()])
    submit = SubmitField('Get My Secret')

def run_example(key_vault_name, secret_name):

    # Get credentials
    credentials = ManagedIdentityCredential()

    print(credentials.token)

    # Construct the vault uri
    key_vault_uri = "https://" + key_vault_name + ".vault.azure.net/"

    #Create a secret client
    secret_client = SecretClient(
        key_vault_uri,
        credentials
    )

    secret = secret_client.get_secret(secret_name)

    return secret.value


@app.route('/', methods = ['POST', 'GET'])
def default_page():
    try:
        form = KVForm()
        if form.validate_on_submit():
            secret = run_example(form.keyVaultName.data, form.secretName.data)
            return render_template('secret_found.html', title='Secret Found', secret=secret, keyVaultName=form.keyVaultName.data, secretName=form.secretName.data)
        return render_template('submit_secret.html', title='Submit Secret Info', form=form)

    except Exception as err:
        return str(err)

@app.route('/ping', methods = ['GET'])
def ping():
    return "Hello Ping"

if __name__ == "__main__":
    # Only for debugging while developing
    app.run(host='0.0.0.0', debug=True, port=80)