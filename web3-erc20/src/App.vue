<script setup>
import { ref,onMounted,computed} from 'vue';
import Web3 from 'web3';
import mtcJSON from './contracts/MyToken.json';

const geerliWS = "wss://goerli.infura.io/ws/v3/0ee78a193e3b4ca1b73f618da27b3cc0";
const web3 = new Web3(Web3.givenProvider || geerliWS);
//前面是Json文件里面的abi，后面的是remix里面运行后生成的一串，复制过来
const mtcContract = new web3.eth.Contract(
  mtcJSON.abi,
  //这一串乱码必须是，remix里面的solidity代码在小狐狸下部署的那个
  "0x312Ee0250b82e1101Ee6FFDBA450D6783DDBCb1E",
  );


//异步函数
//代币信息：
const name = ref("");
const symbol = ref("");
const totalSupply = ref("");
const balanceOf = ref(0);
const currentAccount = ref("");

//转账信息
const toAddress = ref("");
const amount= ref("0");

const getCoinInfo = async () =>{
  const account = await web3.eth.requestAccounts();
  currentAccount.value = account;
  
  //这里面的name（）其实就是我自己在remix里面定义的方法，call（）其实就是响应/启动之类的意思，不消耗gas的一种方法
  name.value = await mtcContract.methods.name().call();
  symbol.value = await mtcContract.methods.symbol().call();
  totalSupply.value = await mtcContract.methods.totalSupply().call();
  //应为当初我在remix里面定义的函数就是要传参的，所以这里有所不同
  balanceOf.value = await mtcContract.methods.balanceOf(account[0]).call();
  
};
const ts = computed(()=>{
  return web3.utils.fromWei(totalSupply.value,"ether");

});
const bo = computed(()=>{
  return web3.utils.fromWei(String(balanceOf.value),"ether");

});
onMounted(()=>{
  getCoinInfo();

});

const send = () =>{
  const weiAmount = web3.utils.toWei(amount.value,"ether");
  mtcContract.methods
  .transfer(toAddress.value,weiAmount)
  .send({

    //不消耗gas的用call，消耗gas的用下面这个。
    from:currentAccount.value[0],
  })
  .on('receipt',()=>{
    console.log("熊王币交易成功！！！，感谢您的使用");
  });
};
</script>
<template>
  <div class="container">
  <div class="top"><h1>熊熊钱包</h1></div>
  <hr>
  <div class="middle">
    <table border="2">
      <tr><th>当前帐号：</th><th><p>{{ currentAccount }}</p></th></tr>
      <tr><th>代币名称：</th><th><p>{{ name }}</p></th></tr>
      <tr><th>代币标识：</th><th><p>{{ symbol }}</p></th></tr>
      <tr><th>发行量：</th><th> <p>{{ ts }}</p></th></tr>
      <tr><th>持有数量：</th><th> <p>{{ bo }}</p></th></tr>
    </table>
  </div>
  <hr>
  
  <div class="under ">
    <p>转入地址：<input type="text" v-model=" toAddress"></p>
    <p>转出金额：<input type="text" v-model="amount"></p>
    
    <button @click="send">开始转帐</button>

  </div>
</div>
</template>

<style lang="less">
  .top{
    color: rgb(245, 255, 47);
    text-align: center;
    background-color: #ec0d0d;
  }
  .middle{
    background-color: #cda56e;
  }
  .under{
    background-color: #ff018d;
  }
  .container {
  display: flex;
  flex-direction: column;
}
</style>