import os

from fabric.api import run, sudo, env, cd, local, prefix, put, lcd, settings
from fabric.contrib.files import exists, sed
from fabric.contrib.project import rsync_project

env.use_ssh_config = True

user = 'deploy'
doc_dir = '/var/www/avoscloud-docs'

project_dir = "."
dist = 'debian'
host_count = len(env.hosts)

tmp_dir = '/tmp/avoscloud-docs' + str(os.getpid())

def _set_user_dir():
    global dist,user,doc_dir
    with settings(warn_only=True):
        issue = run('id ubuntu').lower()
        if 'id: ubuntu' in issue:
            dist = 'debian'
        elif 'uid=' in issue:
            dist = 'ubuntu'
            user = 'ubuntu'
            doc_dir = '/mnt/avos/avoscloud-docs'


def _clean_local():
    local("rm -rf %s" % (tmp_dir))


def prepare_remote_dirs():
    _set_user_dir()
    if not exists(doc_dir):
        sudo('mkdir -p %s' % doc_dir)
    sudo('chown %s %s' % (user, doc_dir))


def _prepare_local_docs(docCommentToken, target):
    local("mkdir -p %s" % tmp_dir)
    local("rm -rf %s/dist/*" % project_dir)
    local("rm -rf %s/md/*" % project_dir)
    ##local("ruby render.rb")
    local("npm install -d")
    if target == 'qcloud':
      local("DOC_ENV=qcloud DOC_COMMENT_TOKEN=%s grunt build --theme=qcloud" % docCommentToken)
    elif target == 'us':
      local("DOC_ENV=us DOC_COMMENT_TOKEN=%s grunt build --theme=us --no-comments" % docCommentToken)
    else:
      local("DOC_ENV=%s DOC_COMMENT_TOKEN=%s grunt build " % (target, docCommentToken))
#    local("mkdir dist/api")
#    local("cp -rfv api/* dist/api/");
#    local("cd dist ; tar zcvf leancloud-docs.tar.gz ./* ; cd ..")
    local("cp -rfv %s/dist/* %s" % (project_dir, tmp_dir))


def _start_on_boot(name, dist):
    if dist == 'debian':
        sudo('update-rc.d %s defaults' % name)
    elif dist == 'ubuntu':
        sudo('update-rc.d %s defaults' % name)
    elif dist == 'centos':
        sudo('/sbin/chkconfig --level 3 %s on' % name)
    else:
        raise ValueError('dist can only take debian, centos')


def deploy_docs(docCommentToken, target='stage'):
    global host_count
    _set_user_dir()
    if (host_count == len(env.hosts)):
        _prepare_local_docs(docCommentToken, target)

    prepare_remote_dirs()
    rsync_project(local_dir=tmp_dir + '/',
                  remote_dir=doc_dir,
                  delete=True)
    host_count -= 1
    if (host_count == 0):
        _clean_local()
