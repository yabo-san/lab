# Recovery Procedure (only when restoring from backup)

## Prerequisites
- Access to Kubernetes cluster with kubectl configured
- Sudo access on the cluster node
- Knowledge of which backup to restore (check /mnt/data/backups/)

1. Scale down SENAITE: kubectl scale deployment ptlsenaite --replicas=0
2. Edit db-restore.yaml with correct backup filename
3. Run restore: kubectl apply -f restore-job.yaml
4. Wait for completion: kubectl wait --for=condition=complete job/senaite-db-restore
5. Scale up SENAITE: kubectl scale deployment ptlsenaite --replicas=1
6. Cleanup: kubectl delete job senaite-db-restore
