# NUWE-Zurich-Cloud-Hackathon


## Decisions taken during the process

In addition to the recommended configuration I personally decided to use [**tflocal**](https://docs.localstack.cloud/user-guide/integrations/terraform/), this made it easier for me to work with localstack and terrafom without having to define endpoints manually.
Therefore most of the commands with terraform I run with the **tflocal** command.

I also make use of an alias to use the AWS CLI without using LocalStack's Endpoind

```bash
alias awslc='aws --endpoint-url=http://localhost:4566'  
```

## Infrastructure created

![Infrastructure Diagram](https://github.com/mdcravero/NUWE-Zurich-Cloud-Hackathon/blob/main/Zurich%20Cloud%20Hackathon%20Diagram.jpg)