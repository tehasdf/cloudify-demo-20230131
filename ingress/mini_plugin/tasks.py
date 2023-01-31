import sys
import os
import time
sys.modules['pydoc'] = sys  # NOQA

from kubernetes import client, utils  # NOQA


def _make_configmap(target):
    return [
        {
            'apiVersion': 'v1',
            'kind': 'ConfigMap',
            'metadata': {
                'name': 'nginx-conf',
            },
            'data': {
                'nginx.conf': """
user nginx;
worker_processes  3;
error_log /dev/stdout info;
events {
  worker_connections  1024;
}
http {
  access_log /dev/stdout;
  log_format  main
          'remote_addr:$remote_addr\t'
          'time_local:$time_local\t'
          'method:$request_method\t'
          'uri:$request_uri\t'
          'host:$host\t'
          'status:$status\t'
          'bytes_sent:$body_bytes_sent\t'
          'referer:$http_referer\t'
          'useragent:$http_user_agent\t'
          'forwardedfor:$http_x_forwarded_for\t'
          'request_time:$request_time';


  server {
      listen       80 default_server;
      location / {
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        chunked_transfer_encoding off;
        proxy_buffering off;
        proxy_cache off;
        proxy_pass http://TARGET;
      }
  }
}
""".replace('TARGET', target)
            }
        }
    ]


def deploy(ctx, *, host, token, path, target, namespace):
    configuration = client.Configuration()
    configuration.api_key_prefix['authorization'] = 'Bearer'
    configuration.api_key["authorization"] = token
    configuration.host = f'https://{host}:6443'
    configuration.verify_ssl = False

    ctx.instance.runtime_properties['namespace'] = namespace

    with client.ApiClient(configuration) as k8s_client:
        configmap = _make_configmap(target)
        yaml_file = os.path.join(
            '/opt/manager/resources/blueprints',
            ctx.tenant_name,
            ctx.blueprint.id,
            path,
        )
        try:
            utils.create_from_yaml(
                k8s_client,
                yaml_objects=configmap,
                namespace=namespace,
                verbose=True,
            )
        except Exception as e:
            ctx.logger.error('error creating configmap: %s', e)
        try:
            utils.create_from_yaml(
                k8s_client,
                yaml_file,
                namespace=namespace,
                verbose=True,
            )
        except Exception as e:
            ctx.logger.error('error creating from file: %s', e)


def destroy(ctx, *, host, token):
    configuration = client.Configuration()
    configuration.api_key_prefix['authorization'] = 'Bearer'
    configuration.api_key["authorization"] = token
    configuration.host = f'https://{host}:6443'
    configuration.verify_ssl = False

    ns = ctx.instance.runtime_properties['namespace']
    with client.ApiClient(configuration) as k8s_client:
        v1 = client.CoreV1Api(k8s_client)
        try:
            v1.delete_namespaced_pod('nginx-test-pod', ns)
        except Exception as e:
            ctx.logger.error('error deleting pod: %s', e)

        try:
            v1.delete_namespaced_config_map('nginx-conf', ns)
        except Exception as e:
            ctx.logger.error('error deleting configmap: %s', e)

        try:
            v1.delete_namespaced_service('nginx-service', ns)
        except Exception as e:
            ctx.logger.error('error deleting service: %s', e)

        nv1 = client.NetworkingV1Api(k8s_client)
        try:
            nv1.delete_namespaced_ingress('ingress-chat', ns)
        except Exception as e:
            ctx.logger.error('error deleting ingress: %s', e)

    ctx.logger.info('just sleep to wait for delete')
    time.sleep(20)
    ctx.logger.info('delete done')
