# MSA Project ver.Terraform
Producer-Consumer / Pub-Sub 관계를 사용하여 느슨한 결합을 가진 구조를 생성 
# Requirements
- Database에서 재고 확인 후 재고가 부족하다면 재고가 없다는 내용을 담은 메시지 페이로드가 주제별로 생성
- 처리되지 않은 메시지를 처리할 다른 공간 필요
- Factory API를 통하여 상품 재고 증가 요청을 전송
- 재고 증가 요청을 받으면 데이터베이스에서 수량 조정 
# Architecture
![image](https://github.com/peachApeach/project3-msa-terraform/assets/106210881/43f9495d-0afa-4eda-84b1-dff31c25d2d0)


# Tools
### ✔️ Tech Stacks
![AWS](https://img.shields.io/badge/AWS-232F3E.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=for-the-badge&logo=express&logoColor=%2361DAFB)
![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)
### ✔️ CI/CD
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)
### ✔️ IaC
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
# Environment Variables
- HOSTNAME : 데이터베이스 호스트명
- USERNAME : 데이터베이스 유저명
- PASSWORD : 데이터베이스 비밀번호
- DATABASE : 사용 데이터베이스명
# API EndPoint
### 1️⃣ Sales API
| Method   | Endpoint                                      | Description                              |
| -------- | ---------------------------------------- | ---------------------------------------- |
| `GET`    | `/procut/donut`                             | 현재 남아있는 재고 출력                      |
| `POST`   | `/checkout`                             | 요청한 제품의 개수 1 차감                       |
### 2️⃣ Factory
| Method   | Endpoint                                      | Description                              |
| -------- | ---------------------------------------- | ---------------------------------------- |
| `POST`   | `/`                             | 요청 내용 Stock Increase Lambda로 전달                       |
### 3️⃣ Stock Increase
| Method   | Endpoint                                      | Description                              |
| -------- | ---------------------------------------- | ---------------------------------------- |
| `POST`   | `/checkout/donut`                             | 요청 제품 재고 증량                       |
