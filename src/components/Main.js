import React, {Component} from 'react';
// import { Navbar } from 'react-bootstrap';
// import { render } from 'react-dom';

class Main extends Component{

    render(){
        return(
            <div id="content">
            <h1>Register Seller</h1>
            <form onSubmit={(event) =>{
                const smartId = this.smartId.value
                const microgrid = this.microgrid.value
                const energyAmount = this.energyAmount.value
                this.props.registerSeller(smartId, microgrid, energyAmount)      
            }}>
                <div className="from-group mr-sm-2">
                    <input
                      id="smartId" type="text" ref ={(input)=>{this.smartId = input}} className="form-control" placeholder="Smart Meter Id" required>
                    </input>    
                </div>

                <div className="from-group mr-sm-2">
                    <input
                      id="microgrid" type="number" min="1" ref ={(input)=>{this.microgrid = input}} className="form-control" placeholder="Microgrid number" required>
                    </input>    
                </div>

                <div className="from-group mr-sm-2">
                    <input
                      id="energyAmount" type="number" min="0" ref ={(input)=>{this.energyAmount = input}} className="form-control" placeholder="Energy to sell" required>
                    </input>    
                </div>
                <button type="submit" className="btn btn-primary">Register seller</button>
            </form>

            <h1>Register Buyer</h1>
            <form>
                <div className="from-group mr-sm-2">
                    <input
                      id="smartId" type="text" className="form-control" placeholder="Smart Meter Id" required>
                    </input>    
                </div>

                <div className="from-group mr-sm-2">
                    <input
                      id="microgrid" type="number" min="1" className="form-control" placeholder="Microgrid number" required>
                    </input>    
                </div>

                <div className="from-group mr-sm-2">
                    <input
                      id="energyRequired" type="number" min="0" className="form-control" placeholder="Energy needed" required>
                    </input>    
                </div>
                <button type="submit" className="btn btn-primary">Register buyer</button>
            </form>
          </div>
          
        );
    }
}

export default Main;