#!/apps/python2.7.6/bin/python2.7

import os, requests, json, argparse, sys


def get_member_connection(bigip, url):
    pass


def get_member_stats(bigip, url):
    response_data = bigip.get(url)
    print '---member stats----'
    print response_data.json()
#    response_json = response_data.json()
#    return response_json['items'][0][poolproperty]


def get_token(bigip, url, creds):
    payload = {}
    payload['username'] = creds[0]
    payload['password'] = creds[1]
    payload['loginProviderName'] = 'tmos'
    token = bigip.post(url, json.dumps(payload)).json()['token']['token']
    return token


if __name__ == "__main__":

    requests.packages.urllib3.disable_warnings()

    parser = argparse.ArgumentParser(description='Queries Properties of a F5 Pool')

    parser.add_argument("--host", help='F5 Host', )
    parser.add_argument("--username", help='F5 Username')
    parser.add_argument("--password", help='F5 Password')
    parser.add_argument("--poolname", help='pool name')

    args = vars(parser.parse_args())

    hostname = args['host']
    username = args['username']
    poolname = args['poolname']
    password = args['password']


    if not hostname:
        print "--hostname required"
        sys.exit()

    if not username:
        print "--username required"
        sys.exit()

    if not poolname:
        print "--poolname required"
        sys.exit()

    if not password:
        print "--password required"
        sys.exit()


    url_base = 'https://%s/mgmt' % hostname
    url_auth = '%s/shared/authn/login' % url_base
    url_stats = '%s/tm/ltm/pool/%s/members/stats' % (url_base, poolname)
    #url_member = '%s/tm/ltm/pool/%s/members/%s/stats' % (url_base, poolname, poolmember)

    b = requests.session()
    b.headers.update({'Content-Type':'application/json'})
    b.auth = (username, password)
    b.verify = False

    token = get_token(b, url_auth, (username, password))
    print '\nToken: %s\n' % token

    b.auth = None
    b.headers.update({'X-F5-Auth-Token': token})

    value = get_member_stats(b, url_stats)
    print value
