# MSA Project ver.Terraform
구독-발행 관계를 사용하여 느슨한 결합을 가진 구조를 생성 
# Requirements
- Database에서 재고 확인 후 재고가 부족하다면 재고가 없다는 내용을 담은 메시지 페이로드가 주제별로 생성
- 처리되지 않은 메시지를 처리할 다른 공간 필요
- Factory API를 통하여 상품 재고 증가 요청을 전송
- 재고 증가 요청을 받으면 데이터베이스에서 수량 조정 
# Architecture
![image](https://github.com/peachApeach/project3-msa-terraform/assets/106210881/b7e9d4e6-daaf-45fa-a699-f6078f2427d5)

