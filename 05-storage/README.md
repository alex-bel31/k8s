# Хранение в K8s

### Задание 1. Volume: обмен данными между контейнерами в поде

* Манифест - [containers-data-exchange.yml
](https://github.com/alex-bel31/k8s/blob/main/05-storage/containers-data-exchange.yml)

    <center>
    <img src="img/t1-describe-pod_1.JPG">
    </center>

    <center>
    <img src="img/t1-describe-pod_2.JPG">
    </center>

    <center>
    <img src="img/t1-tail.JPG">
    </center>

### Задание 2. PV, PVC

1. Манифест - [pv-pvc.yml
](https://github.com/alex-bel31/k8s/blob/main/05-storage/pv-pvc.yml)

    <center>
    <img src="img/t2-tail.JPG">
    </center>

2. PV останется, но перейдёт в статус Released, но его нельзя будет перепривязать к новому PVC, пока существует старая привязка. Данные в /mnt/data сохраняются, так как выбранная ReclaimPolicy - Retain.

    <center>
    <img src="img/t2-describe-pv.JPG">
    </center>

3. Директория /mnt/data не удалилась, потому что hostPath — это ссылка на локальный путь, и k8s не управляет ее жизненным циклом. Удаление PV не трогает файловую систему узла.

    <center>
    <img src="img/t2-del-pv.JPG">
    </center>


### Задание 3. StorageClass


1. Манифест - [sc.yml
](https://github.com/alex-bel31/k8s/blob/main/05-storage/sc.yml)

    <center>
    <img src="img/t3-tail.JPG">
    </center>