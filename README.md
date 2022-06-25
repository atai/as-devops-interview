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

1. (+) Приложение размещено в хранилище git.
2. (+) Python 3.9 flack app. Зависимости в requirements.txt. Интерфейсная часть и backend в двух отдельных файлах.
3. (+) Варианты разворачивания приложения:
   1. [Elastic Beanstalk(EB)](https://docs.aws.amazon.com/elastic-beanstalk/index.html)
   2. [Elastic Container Service(ECS)](https://docs.aws.amazon.com/ecs/index.html)
   3. Kubernetes
   4. EC2 instance
4. (-) IaC подход, предполагает использование таких инструментов как AWS CloudFormation или Terraform. 
   1. AWS файлы развертывания проще и короче.
   2. Terraform "провайдеронезависимый" - можно использовать on-premises ресурсы или ресурсы разных провайдеров.
   3. Для данной реализации использован Terraform. Файлы реализации в папке ./terraform.
   4. Созданные ресурсы:
      1. Для EB:
         1. _df_
      2. Для ECS:
         1. _df_
5. (-) Принцип минимальных привилегий предполагает выдачу минимально необходимого для выполнения задачи прав.
   1. В случае с EB это:
      1. To upload an object encrypted with an AWS KMS key to Amazon S3, you need kms:GenerateDataKey permissions on the key
      2. 
   2. В случае с ECS это:
      1. To upload an object encrypted with an AWS KMS key to Amazon S3, you need kms:GenerateDataKey permissions on the key
      2. 
6. (+) Шифрование включено в настройках S3 bucket в момент создания.
7. (-) Настройки доступа в интернет запрещающие доступ в публичную сеть включены при создании ресурсов.
8. (+) Время на реализацию каждого варианта 1-2 часа.
9. (-) Ориентировочные затраты можно подсчитать с помощью [AWS Pricing Calculator](https://calculator.aws/): 
   1. EB [calculation]().
   2. ECS [calculation]().
10. (+) Трудоемкость сопровождения определяется в рамках [shared responsibility model](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/vulnerability-analysis-and-management.html). 
Ответственность провайдера выше в модели PaaS (EB) чем в случае IaaS(EC2).  
Обновление зависимостей:
    1. Для EB можно автоматизировать отслеживание и установку минорных обновлений с помощью инструментов AWS. 
    2. Для ECS варианта нужно периодически обновлять докер образ и самостоятельно следить за устареванием и уязвимостями библиотек. 
    Можно сканировать докер регистр на предмет устаревших/уязвимых библиотек.
11. (+) Ограничения:
    1. Для EB [link](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/applications-lifecycle.html), [link](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html).
    2. Для ECS [link](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-quotas.html).