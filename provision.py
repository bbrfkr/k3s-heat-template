import os
import sys
import yaml
import json
from keystoneauth1.identity import v3
from keystoneauth1 import loading
from keystoneauth1 import session
from heatclient import client

CONFIG_FILENAME = 'config.yaml'
TEMPLATE_DIR = 'templates/'
TEMPLATE_FILENAME = 'k3s_cluster.yaml'
TEMPLATE_FILE = TEMPLATE_DIR + TEMPLATE_FILENAME
SCRIPT_DIR = 'fragments/'

# Create heat client
auth = v3.Password(
    auth_url=os.environ['OS_AUTH_URL'],
    username=os.environ['OS_USERNAME'],
    password=os.environ['OS_PASSWORD'],
    project_name=os.environ['OS_PROJECT_NAME'],
    user_domain_name=os.environ['OS_USER_DOMAIN_NAME'],
    project_domain_name=os.environ['OS_PROJECT_DOMAIN_NAME']
)
sess = session.Session(auth=auth)
heat = client.Client('1', session=sess)

# test
template_file = open(TEMPLATE_FILE, 'r')
template = yaml.safe_load(template_file)

config_file = open(CONFIG_FILENAME, 'r')
config = yaml.safe_load(config_file)

environment = {}
is_none_network = config['parameters']['private_network'] is None
is_none_subnet = config['parameters']['private_subnet'] is None
if is_none_network and is_none_subnet:
    environment_file = open('environments/with_private_network.yaml')
    environment = yaml.safe_load(environment_file)
elif (not is_none_network) and (not is_none_subnet):
    environment_file = open('environments/no_private_network.yaml')
    environment = yaml.safe_load(environment_file)
else:
    sys.exit('ERROR: specifying only private_network or private_subnet is not allowed.')
environment.update(config)

subtemplates = {}
subtemplates_filenames = (os.listdir(TEMPLATE_DIR))
subtemplates_filenames.remove(TEMPLATE_FILENAME)
for subtemplate_filename in subtemplates_filenames:
    subtemplate_file = open(TEMPLATE_DIR + subtemplate_filename)
    subtemplate = json.dumps(yaml.safe_load(subtemplate_file))
    subtemplates[subtemplate_filename] = subtemplate

scripts = {}
scripts_filenames = (os.listdir(SCRIPT_DIR))
for script_filename in scripts_filenames:
    script_file = open(SCRIPT_DIR + script_filename)
    script = script_file.read()
    scripts[script_filename] = script

files = dict(subtemplates.items() + scripts.items())

if len(sys.argv) == 1:
    sys.exit('Usage: python provision.py [stack name]')
fields = {
    'stack_name': sys.argv[1],
    'template': template,
    'environment': environment,
    'files': files
}

stack_id = heat.stacks.create(**fields)['stack']['id']
print('created stack id: ' + stack_id)