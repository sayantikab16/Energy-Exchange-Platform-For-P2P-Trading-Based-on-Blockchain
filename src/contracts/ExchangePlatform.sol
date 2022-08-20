pragma solidity ^0.5.16;
// pragma experimental ABIEncoderV2;

contract ExchangePlatform{
//Name of the smart contract 
string public name;

//Mappings 
mapping(string => Seller) public sellersMap;        //seller smart id is key and seller object is value
mapping(string => Buyer) public buyersMap;         //buyer smart id is key and buyer object is value
mapping(uint => Seller[]) public gridMap;         //grid number is key and grid array is value

//Arrays
Seller[] public sellersArr;   //Array of sellers
Seller[] public grid1;       //Array of sellers in microgrid 1
Seller[] public grid2;      //Array of sellers in microgrid 2
Seller[] public grid3;     //Array of sellers in microgrid 3

//Global variables
uint public TED = 0;
uint public TES = 0; 
uint public demand = 0;
uint public supply = 0;
uint public pay = 0; 
bool public allow = false; 
address payable seller = 0x0000000000000000000000000000000000000000; 

//Seller object
struct Seller{
    string smartId;           //SamrtId of the seller
    address payable owner;   //Wallet Address of the seller
    uint microgrid;         //Microgrid number
    uint energyAmount;     //Energy to be sold
    bool sellStatus;     //seller available for selling if true     
}

//Buyer object
struct Buyer{
    string smartId;            //SamrtId of the buyer
    address payable owner;    //Wallet Address of the buyer
    uint microgrid;          //Microgrid number
    uint energyReq;         //Energy required by buyer
    bool receiveStatus;    //Buyer can buy if false
}

constructor() public {
    name = "Energy trading Platform"; //Name of the contract

    //Mapping of the microgrid arrays
    gridMap[1] = grid1; 
    gridMap[2] = grid2;
    gridMap[3] = grid3;
}

//Events: 

event Time( 
    bool allow
);

event Updated(
    uint TED,
    uint TES, 
    uint demand, 
    uint supply
);

event SellerChecked(
    string smartId,
    address payable owner,
    uint microgrid,
    uint energyAmount,
    bool sellStatus
);

event ArrayUpdated(
    bool updated
);

//Event for creation of seller
event SellerCreated(
    bool created
);

//Event for creation of buyer
event BuyerCreated(
    string smartId,
    address payable owner,  
    uint microgrid, 
    uint energyReq, 
    bool receiveStatus
);

event BuyerChecked(
    string smartId,
    address payable owner,  
    uint microgrid, 
    uint energyReq, 
    bool receiveStatus
);

event RequestCompleted(
    string smartId,
    address payable owner,  
    uint microgrid, 
    uint energyReq, 
    bool receiveStatus
);

event PriceCalculated(
   uint price
);

event EPVcalculated(
   uint EPV
);

event SellerUpdated(
    uint sup,
    bool done
);

event SellerRemoved(
    uint rm,
    bool done
);
//Checks the time and sets global variable allow
function checkTime(uint _time) public {
    _time % 60 >= 0 && _time % 60 <= 15 ? allow = true : allow = false;
    emit Time(allow); 
}

//Updates the TED, TES, demand and supply 
function update(string memory _smartId, uint _energyDealt) public {
   
   //Time of registration 
   if(allow == true){   
       //Checks sender for seller
       if(msg.sender == sellersMap[_smartId].owner){
        //Previous cycle's energy supply added to new cycle
        supply != 0 ? TES = TES + supply + sellersMap[_smartId].energyAmount : TES = TES + sellersMap[_smartId].energyAmount;
        //Current cycle's supply updated
        supply = supply + TES;
       }
       
       //Sender is buyer 
       else{
        //Previous cycle's energy deamn is added to new cycle
        demand != 0 ? TED = TED + demand + buyersMap[_smartId].energyReq : TED = TED + buyersMap[_smartId].energyReq;
        //Current cycle's demand updated
        demand = demand + TED; 
       }
   }

   //Time of transaction 
   if(allow == false){
      //Energy sold subtracted from Current cycle's demand and supply
      demand = demand - _energyDealt;
      supply = supply - _energyDealt;
   }
   
   emit Updated(TED, TES, demand, supply);
}

//Registeration of seller
function registerSeller(string memory _smartId, uint _microgrid, uint _energyAmount) public {
    
    //Checks validity of seller
    require(allow == true); //Registeration only for the first 15 mins of an hour 
    require(bytes(_smartId).length >=9 && bytes(_smartId).length <=12); //SmartId validity
    require(_microgrid > 0 && _microgrid < 4); //Microgrid validity
    require(_energyAmount > 0);  //Energy amount validity

    //Seller cannot be buyer in the same cycle
    //Seller was buyer in previous cycle
    if(msg.sender == buyersMap[_smartId].owner){
        //Check if still a buyer
        require(buyersMap[_smartId].receiveStatus == true); 
        //Create new seller of modify existing
        checkSeller(_smartId, _microgrid, _energyAmount);
    }
    
    //Seller was not buyer in previous cycle
    else{
        //Create new seller of modify existing
        checkSeller(_smartId, _microgrid, _energyAmount);
    }

    //Update the TED, TES, demand and supply
    update(_smartId,0);
    
    //Trigger the event of seller creation 
    //emit SellerCreated(true);
}

function checkSeller(string memory _smartId, uint _microgrid, uint _energyAmount) public{

  //Seller already exists  
  if(msg.sender == sellersMap[_smartId].owner){
    //Not an active seller
     if(sellersMap[_smartId].sellStatus == false){
        sellersMap[_smartId].sellStatus = true; //Turn sellStatus true
        sellersMap[_smartId].energyAmount = _energyAmount; //Update new energy amount
      }

     //sellStatus is true
     else{
        sellersMap[_smartId].energyAmount += _energyAmount; //Add to the energy Amount 
      }       

      updateArr(_smartId, _microgrid, _energyAmount); //Update the sellers array and microgrid
    } 

   //Seller does not exist 
   else{
     //Create new seller and add to map and microgrid
     sellersMap[_smartId] =  Seller(_smartId, msg.sender, _microgrid, _energyAmount, true); //Maps the seller's smartId to the seller object
     sellersArr.push( Seller(_smartId, msg.sender, _microgrid, _energyAmount, true));  //Adds the seller object to the array of sellers 
     gridMap[_microgrid].push(sellersMap[_smartId]); 
    }

    emit SellerChecked(_smartId, msg.sender, _microgrid, _energyAmount, true);
}


function updateArr(string memory _smartId, uint _grid, uint _energyAmount) public {

    //Update Sellersarr  
    string memory _id;
    for(uint i = 0; i < sellersArr.length; i++){
        _id = sellersArr[i].smartId;
        if(keccak256(abi.encodePacked(_id)) == keccak256(abi.encodePacked(_smartId))){
            sellersArr[i].energyAmount += _energyAmount;
            
            if(sellersArr[i].sellStatus == false ){
               sellersArr[i].sellStatus = true;
            }  
        } 
    }
    
    //Update the microgrid
    for(uint i = 0; i < gridMap[_grid].length; i++){
        _id = gridMap[_grid][i].smartId;
        if(keccak256(abi.encodePacked(_id)) == keccak256(abi.encodePacked(_smartId))){
            gridMap[_grid][i].energyAmount += _energyAmount;
            if(sellersArr[i].sellStatus == false ){
               sellersArr[i].sellStatus = true;
            }  
        } 
     }
    
    emit ArrayUpdated(true);
}

//Registeration of Buyer 
function registerBuyer(string memory _smartId, uint _microgrid, uint _energyReq) public {

    require(allow == true);
    require(bytes(_smartId).length >=9 && bytes(_smartId).length <=12);
    require(_microgrid > 0 && _microgrid < 4);

     //Buyer can not be seller in the same cycle
     //Buyer was seller in previous cycle
     if(msg.sender == sellersMap[_smartId].owner){
        //Buyer is not seller in current cycle
        require(sellersMap[_smartId].sellStatus == false);
        //Create new buyer or update existing 
        checkBuyer(_smartId, _microgrid, _energyReq);
    }    

    else{
        //Create new buyer or update existing 
        checkBuyer(_smartId, _microgrid, _energyReq);
    }
    
    //Update the TED, TES, demand and supply
    update(_smartId,0);

    //Triggers event of buyer creation 
    //emit BuyerCreated(_smartId, msg.sender, _microgrid, _energyReq, false);
}

function checkBuyer(string memory _smartId, uint _microgrid, uint _energyReq) public {
    //Buyer already exists
    if(msg.sender == buyersMap[_smartId].owner){
       //Buyer's request of previous cycle fulfilled
       if(buyersMap[_smartId].receiveStatus == true){
          buyersMap[_smartId].receiveStatus = false; //Can recieve energy 
          buyersMap[_smartId].energyReq = _energyReq; //Update the energy required 
        }
        
        //Buyer's request of previous cycle was not fullfilled
        else{
          buyersMap[_smartId].energyReq += _energyReq; //Update the energy required
        }  

        // emit BuyerChecked(true);
    } 
    
    //Buyer does not exist 
    else{
        //Create new buyer
        buyersMap[_smartId] =  Buyer(_smartId, msg.sender, _microgrid, _energyReq, false); //Maps the seller's smartId to the seller object
        // emit BuyerChecked(false);
    }    

    emit BuyerChecked(_smartId, msg.sender, _microgrid, _energyReq, false);
}

//Buy request 
function buyRequest(string memory _smartId, uint _energyNeed) public payable{

    require(allow == false); //Transaction time 
    require(msg.sender == buyersMap[_smartId].owner); //Buy request needs to be sent by buyer

    Buyer memory _buyer = buyersMap[_smartId]; //fetch the buyer
  
    uint _cost = 0; 
    uint _EPV = 0;
    uint _energyRec = 0;
    bool _handled = false;

    //Calculating price for each seller
    _EPV = basePriceCalculation();

    for(uint i = 0; i<gridMap[_buyer.microgrid].length; i++){
       if(_handled == false){
        //Energy present satisfies energy need 
        if(gridMap[_buyer.microgrid][i].energyAmount >= _energyNeed){
             //Seller should be available for selling
             if(gridMap[_buyer.microgrid][i].sellStatus == true){
                  _cost = _energyNeed * _EPV * 10970000000000;  //Calcualte the cost 
                //    require(msg.sender.balance >= _cost, 'Not enough ether'); //Check the balance of buyer
                   gridMap[_buyer.microgrid][i].energyAmount -= _energyNeed;//Update the seller energy amount in grid map 

                     //All energy sold 
                     if(gridMap[_buyer.microgrid][i].energyAmount == 0){
                        gridMap[_buyer.microgrid][i].sellStatus = false; // Cannot sell anymore 
                        //Update in sellers map
                        sellersMap[gridMap[_buyer.microgrid][i].smartId].sellStatus = false; 
                        sellersMap[gridMap[_buyer.microgrid][i].smartId].energyAmount = 0;
                        removeSeller(gridMap[_buyer.microgrid][i].smartId, 1);//Remove seller from  sellers array
                    }

                    //Some energy left with seller
                    else{
                       sellersMap[gridMap[_buyer.microgrid][i].smartId].energyAmount -= _energyNeed; //Update in the map 
                       updateSeller(gridMap[_buyer.microgrid][i].smartId, 1);  //Update the sellers array 
                    }
             
                    _energyRec = _energyNeed;
                    seller = gridMap[_buyer.microgrid][i].owner;
                    _handled = true;
            }   

            else{
                _handled == false;
             }
        }

        //Energy present does not satisfy the need 
        else{
            //Seller should be available for selling  
            if(gridMap[_buyer.microgrid][i].sellStatus == true){
                _cost = gridMap[_buyer.microgrid][i].energyAmount * _EPV * 10970000000000;  //Calculate the cost
               _energyRec = _energyNeed - gridMap[_buyer.microgrid][i].energyAmount; //Update the energy recieved  
               gridMap[_buyer.microgrid][i].energyAmount = 0; //Complete energy of seller used 
               gridMap[_buyer.microgrid][i].sellStatus = false; //Cannot sell anymore 

              //Update in sellers Map 
              sellersMap[gridMap[_buyer.microgrid][i].smartId].sellStatus = false; 
              sellersMap[gridMap[_buyer.microgrid][i].smartId].energyAmount = 0;

              updateSeller(gridMap[_buyer.microgrid][i].smartId, 1);  //Update in sellers array 
              _handled = true; 
              seller = gridMap[_buyer.microgrid][i].owner;
            } 

            else{
                _handled = false;
            }
        }
    }
} 
         
    //Energy need not fullfilled by same microgrid  
    
      //Search the seller's array
      for(uint i = 0; i <= sellersArr.length; i++){
        if(_handled == false){
                 //The microgrid cannot be same 
        if(sellersArr[i].microgrid != _buyer.microgrid){
              //Seller satisfies energy need 
            if(sellersArr[i].energyAmount >= _energyNeed){
                //Seller should be available for selling 
               if(sellersArr[i].sellStatus == true){
                  _cost = 2 * _energyNeed * _EPV * 10970000000000 ; //Calcualte the cost 
                  sellersArr[i].energyAmount -= _energyNeed;   //update the energy amount in sellers array 
                //All energy sold 
                  if(sellersArr[i].energyAmount == 0){
                     sellersArr[i].sellStatus = false; // Cannot sell anymore 
                     //Update in sellers map
                     sellersMap[sellersArr[i].smartId].sellStatus = false; 
                     sellersMap[sellersArr[i].smartId].energyAmount = 0;
                     //Remove seller from  grid array
                     removeSeller(sellersArr[i].smartId, 2);
                  }

                  //Some energy left with seller
                  else{
                     sellersMap[sellersArr[i].smartId].energyAmount -= _energyNeed; //Update in the sellers map 
                     updateSeller(sellersArr[i].smartId, 2); //Update the grid array 
                  }
                  _energyRec = _energyNeed;
                  seller = sellersArr[i].owner;
                  _handled = true; 
               }

                else{
                    _handled = false;
               }
           } 

            else { 
                //Seller should be available for selling 
                if(sellersArr[i].sellStatus == true){
                    _cost = 2 * sellersArr[i].energyAmount * _EPV * 10970000000000;  //Calculate the cost
                    _energyRec = _energyNeed - sellersArr[i].energyAmount; //Update the energy need  
                    sellersArr[i].energyAmount = 0; //Complete energy of seller used 
                    sellersArr[i].sellStatus = false; //Cannot sell anymore 

                    //Update in sellers Map 
                    sellersMap[sellersArr[i].smartId].sellStatus = false; 
                    sellersMap[sellersArr[i].smartId].energyAmount = 0;

                    updateSeller(sellersArr[i].smartId, 2); //Update in grid array  
                    seller = sellersArr[i].owner;
                    _handled = true;
                  }
                
                  else{
                      _handled = false;
                  }
               }
           }
        }
    }
    
    //Update buyer
    buyersMap[_smartId].energyReq = _energyNeed - _energyRec; 
    buyersMap[_smartId].energyReq == 0 ? buyersMap[_smartId].receiveStatus = true : buyersMap[_smartId].receiveStatus = false;
    
    //Update the TED, TES, demand and supply
    update(_smartId, _energyRec);
    //Update pay 
    pay = _cost;
    emit RequestCompleted(_buyer.smartId, msg.sender, _buyer.microgrid, buyersMap[_smartId].energyReq, buyersMap[_buyer.smartId].receiveStatus);
}  



function payment() public payable{
      address payable _seller = seller;
      if(seller != 0x0000000000000000000000000000000000000000){
          _seller.transfer(msg.value);
      }    

      pay = 0; 
}

function basePriceCalculation() public returns (uint){

    uint _GDR = 0; 
    uint _EPV = 0; 
    uint _EPU = 6;

    _GDR = TES/TED;

    if(_GDR >= 1){

        _EPV = _EPU/_GDR;

        if(_EPV == 0){
           _EPV = 1;
        }      
    }

    else{
        _EPV = _EPU; 
    }
    
    emit EPVcalculated(_EPV);
    return _EPV;
}

function updateSeller(string memory _smartId, uint _x) public {

    uint _grid = sellersMap[_smartId].microgrid; 
    string memory _id; 
    
    if(_x == 1){
     for(uint i = 0; i < sellersArr.length; i++){
        _id = sellersArr[i].smartId;
        if(keccak256(abi.encodePacked(_id)) == keccak256(abi.encodePacked(_smartId))){
           sellersArr[i].energyAmount = sellersMap[_smartId].energyAmount;
        }
      }
      emit SellerUpdated(_x, true);
    }
    
    if(_x == 2){
      for(uint i = 0; i < gridMap[_grid].length; i++){
        _id = gridMap[_grid][i].smartId;
        if(keccak256(abi.encodePacked(_id)) == keccak256(abi.encodePacked(_smartId))){
           gridMap[_grid][i].energyAmount -= sellersMap[_smartId].energyAmount;
        }
      }
      emit SellerUpdated(_x, false);
    }  
}

function removeSeller(string memory _smartId, uint _x) public {
    
    uint _grid = sellersMap[_smartId].microgrid;
    string memory _id;
    
    if(_x == 1){
      for(uint i = 0; i < sellersArr.length; i++){
        _id = sellersArr[i].smartId;
        if(keccak256(abi.encodePacked(_id)) == keccak256(abi.encodePacked(_smartId))){
            sellersArr[i] = sellersArr[i+1];
        } 
      }
      delete sellersArr[sellersArr.length - 1];
     emit SellerRemoved(_x, true);
    }

    if(_x == 2){
     for(uint i = 0; i < gridMap[_grid].length; i++){
        _id = gridMap[_grid][i].smartId; 
        if(keccak256(abi.encodePacked(_id)) == keccak256(abi.encodePacked(_smartId))){
            gridMap[_grid][i] = gridMap[_grid][i+1];
        } 
      }
      delete gridMap[_grid][gridMap[_grid].length - 1]; 
      emit SellerRemoved(_x, true);
    }
  }
}