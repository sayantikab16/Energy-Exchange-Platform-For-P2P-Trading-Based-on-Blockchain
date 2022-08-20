import React, { Component } from 'react';
import Web3 from 'web3';
import logo from '../logo.png';
import './App.css';
import ExchangePlatform from "../abis/ExchangePlatform.json";
import Navbar from './Navbar'
import Main from './Main'
import Popup from 'reactjs-popup';
import 'reactjs-popup'


class App extends Component {
  
  async componentWillMount(){
    await this.loadWeb3()
    await this.loadBlockchainData()
  }

  async loadWeb3(){
    if(window.ethereum){
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable()
    }
    else if(window.web3){
      window.Web3 = new Web3(window.web3.currentProvider)
    }
    else{
      window.alert('Non ethereum browser detected.')
    }
  }

  async loadBlockchainData(){
    const web3 = window.web3
    const accounts = await web3.eth.getAccounts()
    this.setState({account: accounts[0]})
    const networkId = await web3.eth.net.getId()
    const networkData = ExchangePlatform.networks[networkId]
    if(networkData){
      const exchange = web3.eth.Contract(ExchangePlatform.abi, networkData.address)
      this.setState({exchange})
      const ted = await exchange.methods.TED().call()
      console.log(ted)
      this.setState({loading: false})
    }
    else{
      window.alert('ExchangePlatform contract not deployed to detected network.')
    }

  }
    
  constructor(props){
    super(props)
    this.state = {
      account: '',
      loading: true
    }

    this.registerSeller = this.registerSeller.bind(this)
  }

  registerSeller(smartId, microgrid, energyAmount){
     this.state.loading({loading: true})
     this.state.marketplace.methods.registerSeller(smartId, microgrid, energyAmount).send({from: this.state.account})
      .once('reciept', (receipt)=>{
        this.state({loading: false})
     })  
  }

  

  render() {
    return (
      <div>
        <Navbar account={this.state.account}/>
        <div className="container-fluid mt-5">
          <div className="row">
             <main role="main" className="col-lg-12 d-flex"> 
             {  this.state.loading
               ? <div id="loader" className="text-center"><p className="text-center">Loading...</p></div>
               : <Main registerSeller={this.registerSeller}/>
             }
               </main>
          </div> 
        </div>
      </div>
  
         
      
    );
  }
}

export default App;
