import React, {Component} from 'react';
// import { Navbar } from 'react-bootstrap';
// import { render } from 'react-dom';

class Navbar extends Component{

    render(){
        return(
            <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
            <h3 className="text-white"> Energy Exchange Platform </h3>
            <ul className="navbar-nav px-3">
            <li className="nav-item text-nowrap d-done d-sm-none d-sm-block">
              <small className="text-white"><span id="account">{this.props.account}</span></small>
            </li>
            </ul> 
            </nav>
        );
    }
}

export default Navbar;