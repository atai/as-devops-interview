# as-devops-interview

## Задание

Дан исходный код приложения: https://github.com/dianephan/flask-aws-storage (актуальная версия 6a374264a707bb4fbfce25ddc9e4ad81cec1ada4) 

Приложение представляет собой форму отправки картинки, и страницу просмотра картинок из S3 бакета. 

Расскажите, как вы развернете приложение в облаке AWS с учетом требований, указанных ниже. 

Требования: 

* Описать инфраструктуру кодом, все необходимые ресурсы необходимо создавать: VPC, S3, RT, ...  
* Используемые политики SG/ACL/IAM и др. должны соответствовать принципу минимальных привилегий  
* S3 бакет должен быть: c шифрованием на стороне AWS (SSE-KMS), и заблокированным публичным доступом (block all public access)  
* Ресурс, где будет выполняться код, не должен иметь доступа в интернет (соответствующая RT не должна содержать 0.0.0.0/0 на IGW или NAT)  

Оцените свое решение с точки зрения времени на реализацию. 

Оцените свое решение с точки зрения стоимости ресурсов (постоянные и переменные затраты). 

Оцените свое решение с точки зрения сложности сопровождения (обновления уязвимых модулей, системных библиотек и т.д.) 

Есть ли какие-то ограничения вашего решения (например, не поддерживает загрузку файлов размером более 512MB, или не более 100 req/s)?

## Решение

1. (+) Приложение размещено в хранилище `git`. В папке `/src`.
2. (+) `Python 3.9 flack app`. Зависимости в `requirements.txt`. Интерфейсная часть и backend в двух отдельных файлах.
3. (+) Варианты разворачивания приложения:
   1. [Elastic Beanstalk(EB)](https://docs.aws.amazon.com/elastic-beanstalk/index.html)
   2. [Elastic Container Service(ECS)](https://docs.aws.amazon.com/ecs/index.html)
   3. Kubernetes
   4. EC2 instance
4. (+) IaC подход, предполагает использование таких инструментов как A`WS CloudFormation` или `Terraform`. 
   1. По моему мнению AWS файлы развертывания проще и короче.
   2. `Terraform` "провайдеронезависимый" - можно использовать on-premises ресурсы или ресурсы разных провайдеров.
   3. Для данной реализации использован `Terraform`. Файлы реализации в папке `/terraform`.
5. (+) Созданные ресурсы:
   1. `Amazon S3 bucket` – A storage location for your source code, logs, and other artifacts that are created when you use Elastic Beanstalk. 
   2. `EC2 instance` – An Amazon Elastic Compute Cloud (Amazon EC2) virtual machine configured to run web apps on the platform that you choose. 
   Each platform runs a specific set of software, configuration files, and scripts to support a specific language version, framework, web container, or combination of these. Most platforms use either Apache or NGINX as a reverse proxy that sits in front of your web app, forwards requests to it, serves static assets, and generates access and error logs. 
   3. `Instance security group` – An Amazon EC2 security group configured to allow inbound traffic on port 80. This resource lets HTTP traffic from the load balancer reach the EC2 instance running your web app. By default, traffic isn't allowed on other ports. 
   4. `Load balancer` – An Elastic Load Balancing load balancer configured to distribute requests to the instances running your application. A load balancer also eliminates the need to expose your instances directly to the internet. 
   5. `Load balancer security group` – An Amazon EC2 security group configured to allow inbound traffic on port 80. This resource lets HTTP traffic from the internet reach the load balancer. By default, traffic isn't allowed on other ports. 
   6. `Auto Scaling group` – An Auto Scaling group configured to replace an instance if it is terminated or becomes unavailable. 
   7. `Amazon CloudWatch alarms` – Two CloudWatch alarms that monitor the load on the instances in your environment and that are triggered if the load is too high or too low. When an alarm is triggered, your Auto Scaling group scales up or down in response. 
   8. `AWS CloudFormation stack` – Elastic Beanstalk uses AWS CloudFormation to launch the resources in your environment and propagate configuration changes. The resources are defined in a template that you can view in the AWS CloudFormation console. 
   9. `Domain name` – A domain name that routes to your web app in the form subdomain.region.elasticbeanstalk.com.
6. (-) Принцип минимальных привилегий предполагает выдачу минимально необходимого для выполнения задачи прав.
   1. В случае с EB это:
      1. To upload an object encrypted with an AWS KMS key to Amazon S3, you need kms:GenerateDataKey permissions on the key
      2.
7. (+) Шифрование включено в настройках S3 bucket в момент создания.
8. (-) Настройки доступа в интернет запрещающие доступ в публичную сеть включены при создании ресурсов.
9. (+) Время на реализацию 2 часа.
10. (+) Ориентировочные затраты можно подсчитать с помощью [AWS Pricing Calculator](https://calculator.aws/). 
Для созданной инфраструктуры ElasticBeanstalk [calculation](https://calculator.aws/#/estimate?id=b666907f2ec3641e58546b7d94b4f34a983e2aa5).
11. (+) Трудоемкость сопровождения определяется в рамках [shared responsibility model](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/vulnerability-analysis-and-management.html). 
Ответственность провайдера выше в модели PaaS (EB) чем в случае IaaS(EC2). 
Это значит, что чем более "управляемый" сервис тем ниже будут трудозатраты на его поддержку (а стоимость сервиса выше).
Обновление зависимостей:
    1. Для EB можно автоматизировать отслеживание и установку минорных обновлений с помощью инструментов AWS. 
    2. Для ECS варианта нужно периодически обновлять докер образ и самостоятельно следить за устареванием и уязвимостями библиотек. 
    Можно сканировать Docker-Registry на предмет устаревших/уязвимых библиотек.
13. (+) Ограничения могут быть обусловлены облачным сервисом или ограничениями используемого программного обеспечения. 
Ограничения платформы описаны в документации:
    1. Для EB [link](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/applications-lifecycle.html), [link](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html).
    2. Для ECS [link](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-quotas.html).