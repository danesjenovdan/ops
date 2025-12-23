# OPS
Ops vsebuje:
* backup skripte za baze in statične podatke
* skripte za čiščenje zastarelih backup datotek
* custom docker file-e za backupe
* kubernetes kustomization konfiguracije (cronjob) za backupe
* kubernetes kustumization konfiguracije (deployment) za self hosted 3th party service in podatkoven baze. Določeni se avtomatično deplyajo, določeni imajo ročni deployment. CD se konfigurira v **djnd-infra** private repositoriju:
| service  | vklopljen CD  |
|:---:|:---:|
| mariadb | ❌ |
| matweb | ✅ |
| memcached | ❌  |
| odoo | ❌  |
| outline | ❌  |
| plausible | ❌  |
| postgresql | ❌  |
| uptime-kuma | ✅ |
| valkey | ❌  |
| weblate | ✅ |
| vodiči redirect | ✅ |
| google workspace redirect | ✅ |
