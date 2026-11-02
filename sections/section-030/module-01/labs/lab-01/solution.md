---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Identify The kube-proxy Boundary Solution

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-058-lab-030-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-058-lab-030-01-01" || exit 1
node_name="astro-ats-058-lab-030-01-01-control-plane"
worker_name="astro-ats-058-lab-030-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

Observe that this baseline retains kube-proxy alongside Cilium. Inspect BPF service state and avoid claiming full kube-proxy replacement from the CNI name alone.

Record observations in `starfleet/evidence`, whose `report.json` contains the stated report. The verifier reads the live API again; invented values do not pass.


Save this as `record.py`:

```python
import json,subprocess,time,sys,tempfile,os

def call(*args):
 r=subprocess.run(list(args),text=True,capture_output=True,timeout=20)
 assert r.returncode==0, 'Observation command failed: '+args[0]
 return r.stdout.strip()
def obj(kind,name,ns='starfleet'):
 return json.loads(call('kubectl',*(['-n',ns] if ns else []),'get',kind,name,'-o','json'))
def api(path):
 script='import urllib.request; print(urllib.request.urlopen('+repr('http://prometheus:9090'+path)+',timeout=8).read().decode())'
 return json.loads(call('kubectl','-n','starfleet','exec','shuttle','--','python','-c',script))
def save(data):
 resource={'apiVersion':'v1','kind':'ConfigMap','metadata':{'name':'evidence','namespace':'starfleet'},'data':{'report.json':json.dumps(data,sort_keys=True)}}
 with tempfile.NamedTemporaryFile(mode='w',suffix='.json',delete=False) as f:json.dump(resource,f);path=f.name
 try:call('kubectl','apply','-f',path)
 finally:os.unlink(path)

assert call('kubectl','config','current-context') == 'kind-astro-ats-058-lab-030-01-01'
pods=json.loads(call('kubectl','-n','kube-system','get','pods','-l','k8s-app=cilium','-o','json'))['items']
pod=sorted(p['metadata']['name'] for p in pods)[0]
text=call('kubectl','-n','kube-system','exec',pod,'--','cilium-dbg','bpf','lb','list')
service=obj('service','probe');assert service['spec']['clusterIP'] in text
report={'service_ip':service['spec']['clusterIP'],'map_has_service':True,'kube_proxy_replacement':obj('configmap','cilium-config','kube-system')['data']['kube-proxy-replacement']}
save(report)
```

Apply the scoped correction:

```sh
python3 record.py
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl -n starfleet get configmaps
kubectl -n starfleet get deployment probe -o yaml
```

Prove the probe Service address is present in a real BPF service map. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.

After recording your result, remove the independent lab with `astrona destroy ats-058-lab-030-01-01`.

## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
