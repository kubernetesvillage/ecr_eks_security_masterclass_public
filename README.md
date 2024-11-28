# ⚠️ EKS Goat: AWS ECR & EKS Security Masterclass ⚠️

<p align="center">
  <img src="/external-images/logo-1.png" alt="Logo" width="500"/>
</p>

### Workshop Website
Access the EKS Security workshop content here:  
[https://ekssecurity.kubernetesvillage.com](https://ekssecurity.kubernetesvillage.com)

### Alternate Link
In case of accessibility issues, you can use the following link:  
[https://ekssecurity.netlify.app/](https://ekssecurity.netlify.app)


> Authored by Anjali Shukla & Divyanshu Shukla for [kubernetesvillage](https://www.linkedin.com/company/kubernetesvillage) community.

[![Netlify Status](https://api.netlify.com/api/v1/badges/fcb91e86-34bf-4621-a1ad-40789fdae187/deploy-status)](https://app.netlify.com/sites/ekssecurity/deploys)

## Workshop Overview

The EKS Goat: AWS ECR & EKS Security Masterclass - From Exploitation to Defense is an immersive workshop designed to take participants through real-world scenarios of attacking and defending Kubernetes clusters hosted on AWS EKS.

This workshop provides a comprehensive approach, from understanding the anatomy of attacks on EKS clusters using AWS ECR to deploying robust defense mechanisms. Participants will learn how to backdoor AWS ECR image & exploit misconfigurations and vulnerabilities within AWS EKS, followed by the implementation of best security practices to safeguard the environment.

- Key Takeaways:
  - Hands-on labs focused on exploiting EKS misconfigurations.
  - Techniques for lateral movement, privilege escalation, and post-exploitation using AWS ECR in AWS EKS .
  - Deep dive into securing AWS EKS clusters by leveraging IAM roles and AWS ECR.

This workshop is tailored for security professionals, cloud engineers, and DevOps teams looking to enhance their understanding of offensive and defensive Kubernetes security strategies.

## 🚀 Prerequisites for EKS Security Workshop 🚀

- ❗ Gmail Account
  - Gmail account to access the documentation.
- 🔧 GitHub Codespace Setup
  - Set up GitHub for Codespace so that the lab can be configured & deployed.
- 🔑 Bring Your Own AWS Account
  - Participants are required to bring an AWS account with billing enabled and admin privileges.
- 💻 Laptop with Browser
  - Laptop with an updated browser (Administrative Privileges if required).

## Setup & Walkthrough Documentation

- [Deployment Documentation](https://ekssecurity.kubernetesvillage.com/)

## Credits

> Reach out in case of missing credits. 

- [Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)
- Credits for image: Offensive Security Say – Try Harder!
- [madhuakula](https://madhuakula.com/kubernetes-goat/docs/owasp-kubernetes-top-ten/)
- [vulhub](https://github.com/vulhub/vulhub/tree/master/jenkins/CVE-2024-23897)
- [Amazon EKS Security Immersion Day](https://github.com/aws-samples/amazon-eks-security-immersion-day)
- [eksworkshop.com - GuardDuty Log Monitoring](https://www.eksworkshop.com/docs/security/guardduty/log-monitoring/)
- [Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)
- [Tech Blog by Anoop Ka - Kyverno](https://tech.groww.in/kyverno-a-kubernetes-native-policy-management-bdd5bc80b8ca)
- [Microsoft Attack Matrix for Kubernetes](https://www.microsoft.com/en-us/security/blog/2020/04/02/attack-matrix-kubernetes/)
- [Datadog Security Labs - EKS Attacking & Securing Cloud Identities](https://securitylabs.datadoghq.com/articles/amazon-eks-attacking-securing-cloud-identities)
- [HackTricks AWS EKS Enumeration](https://cloud.hacktricks.xyz/pentesting-cloud/aws-security/aws-services/aws-eks-enum)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/security/docs/)
- [Amazon EMR IAM Setup for EKS](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html)
- [AWS EKS Pod Identities](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)
- [Anais URL - Container Image Layers Explained](https://anaisurl.com/container-image-layers-explained/)
- [GitLab - Beginner’s Guide to Container Security](https://about.gitlab.com/topics/devsecops/beginners-guide-to-container-security/)
- [Wiz.io Academy - What is Container Security](https://www.wiz.io/academy/what-is-container-security)
- [JFrog Blog - 10 Helm Tutorials](https://jfrog.com/blog/10-helm-tutorials-to-start-your-kubernetes-journey/)
- [Datadog Security Labs - EKS Cluster Access Management](https://securitylabs.datadoghq.com/articles/amazon-eks-attacking-securing-cloud-identities/#authorization-eks-cluster-access-management-recommended)
- [ChatGPT - For Re-phrasing & Re-writing](https://chatgpt.com)
- [Okey Ebere Blessing - AWS EKS Authentication & Authorization](https://okeyebereblessing.medium.com/how-to-configure-and-manage-authentication-and-authorization-in-aws-elastic-kubernetes-service-367a49ab3f9f)
- [Microsoft Blog - Attack Matrix for Kubernetes](https://www.microsoft.com/en-us/security/blog/2020/04/02/attack-matrix-kubernetes/)
- [Subbaraj Penmetsa - OPA Gatekeeper for Amazon EKS](https://medium.com/@subbarajpenmetsa/open-policy-agent-opa-gatekeeper-for-amazon-eks-507dd1edc72d)
- [Open Policy Agent GitHub](https://github.com/open-policy-agent)
- [OPA Gatekeeper Documentation](https://open-policy-agent.github.io/gatekeeper/website/docs/)
- [Gatekeeper Library on GitHub](https://github.com/open-policy-agent/gatekeeper-library)
- [CDK EKS Blueprints - OPA Gatekeeper](https://aws-quickstart.github.io/cdk-eks-blueprints/addons/opa-gatekeeper/)
- [AWS EKS Documentation](https://aws.amazon.com/eks/)
- [Datadog Security Labs - EKS Attacking & Securing Cloud Identities](https://securitylabs.datadoghq.com/articles/amazon-eks-attacking-securing-cloud-identities/)
- [Cloud HackTricks Kubernetes Enumeration](https://cloud.hacktricks.xyz/pentesting-cloud/kubernetes-security/kubernetes-enumeration)
- [ Attacking & Defending Kubernetes training](https://www.linkedin.com/in/peachycloudsecurity/)

## Disclaimer

- The information, commands, and demonstrations presented in this course, **AWS EKS Red Team Masterclass - From Exploitation to Defense**, are intended strictly for educational purposes. Under no circumstances should they be used to compromise or attack any system outside the boundaries of this educational session unless explicit permission has been granted.

    - <b>This course is provided by the instructors independently and is not endorsed by their employers or any other corporate entity. The content does not necessarily reflect the views or policies of any company or professional organization associated with the instructors.</b>

- **Usage of Training Material**: The training material is provided without warranties or guarantees. Participants are responsible for applying the techniques or methods discussed during the training. The trainers and their respective employers or affiliated companies are not liable for any misuse or misapplication of the information provided.

- **Liability**: The trainers, their employers, and any affiliated companies are not responsible for any direct, indirect, incidental, or consequential damages arising from the use of the information provided in this course. No responsibility is assumed for any injury or damage to persons, property, or systems as a result of using or operating any methods, products, instructions, or ideas discussed during the training.

- **Intellectual Property**: This course and all accompanying materials, including slides, worksheets, and documentation, are the intellectual property of the trainers. They are shared under the Apache License 2.0, which requires that appropriate credit be given to the trainers whenever the materials are used, modified, or redistributed.

- **References**: Some of the labs referenced in this workshop are based on open-source materials available at [Amazon EKS Security Immersion Day](https://github.com/aws-samples/amazon-eks-security-immersion-day) GitHub repository, licensed under the MIT License. Additionally, modifications and fixes have been applied using AI tools such as Amazon Q, ChatGPT, and Gemini.

- **Educational Purpose**: This lab is for educational purposes only. Do not attack or test any website or network without proper authorization. The trainers are not liable or responsible for any misuse.
- **Usage Rights**: Individuals are permitted to use this course for instructional purposes, provided that no fees are charged to the students.




> Note: Currently unable to provide the support in case facing any deployment issue. This lab is for educational purposes only. Do not attack or test any website or network without proper authorization. The trainers are not liable or responsible for any misuse and this course provided independently and is not endorsed by their employers or any other corporate entity. Refer to disclaimer section at [ekssecurity.kubernetesvillage.com](https://ekssecurity.kubernetesvillage.com/welcome/introduction#disclaimer)



