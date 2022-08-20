// const { assert } = require("chai")
// const { Item } = require("react-bootstrap/lib/Breadcrumb")

const { assert } = require("chai")

//const { assert } = require("chai")

const ExchangePlatform = artifacts.require('./ExchangePlatform.sol')

contract('ExchangePlatform', ([deployer, seller1, seller2, buyer1, buyer2])=>{
    let exchange 

    before(async ()=>{
        exchange = await ExchangePlatform.deployed()
    })

    describe('deployment', async ()=>{
        it('deploys successfully', async ()=>{
            const address = await exchange.address
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
        })

        it('has a name', async ()=>{
            const name = await exchange.name()
            console.log(name.logs)
            assert.equal(name, 'Energy trading Platform')
        })
    })


    describe('time', async ()=>{
        let result, allow
        before(async ()=>{
            result = await exchange.checkTime(15)
            allow = await exchange.allow()
        })

        it('checks time', async ()=>{
            //success
            assert.equal(allow, true)
            
        })
    })


    describe('register sellers', async ()=>{
        let time, allow, seller, ted, tes, supply, demand
        before(async ()=>{
            time = await exchange.checkTime(15)
            allow = await exchange.allow()
            seller = await exchange.registerSeller('AF20F6285X', 1, 2400, {from: seller1})
            ted = await exchange.TED()
            tes = await exchange.TES()
            supply = await exchange.supply()
            demand = await exchange.demand()
        })

        it('registers sellers', async ()=>{
            //success
            assert.equal(allow, true)
            assert.equal(ted, 0)
            assert.equal(tes, 2400)
            assert.equal(supply, 2400)
            assert.equal(demand, 0)
        })
    })


    describe('create and update sellers', async ()=>{
        let seller
        before(async ()=>{
            seller = await exchange.checkSeller('AF20F6285X', 1, 2400, {from: seller1})
        })

        it('creates and updates sellers', async ()=>{
            //success
            console.log(seller.logs)
            const event = seller.logs[1].args
            assert.equal(event.smartId, 'AF20F6285X', 'correct smartId')
            assert.equal(event.owner, seller1, 'correct owner')
            assert.equal(event.microgrid, 1, 'correct microgrid')
            assert.equal(event.energyAmount, 2400, 'correct energy amount')
            assert.equal(event.sellStatus, true, 'correct sell status')
        })
    })


    describe('register buyers', async ()=>{
        let time, allow, seller, ted, tes, supply, demand
        before(async ()=>{
            time = await exchange.checkTime(15)
            allow = await exchange.allow()
            seller = await exchange.registerBuyer('BG21S6285Y', 1, 2400, {from: buyer1})
            ted = await exchange.TED()
            tes = await exchange.TES()
            supply = await exchange.supply()
            demand = await exchange.demand()
        })

        it('registers buyers', async ()=>{
            //success
            assert.equal(allow, true)
            assert.equal(ted, 2400)
            assert.equal(tes, 2400)
            assert.equal(supply, 2400)
            assert.equal(demand, 2400)
        })
    })


    describe('create and update buyers', async ()=>{
        let buyer
        before(async ()=>{
            buyer = await exchange.checkBuyer('BG21S6285Y', 1, 2400, {from: buyer1})
        })

        it('creates and updates buyers', async ()=>{
            //success
            console.log(buyer.logs)
            const event = buyer.logs[0].args
            assert.equal(event.smartId, 'BG21S6285Y', 'correct smartId')
            assert.equal(event.owner, buyer1, 'correct owner')
            assert.equal(event.microgrid, 1, 'correct microgrid')
            assert.equal(event.energyReq, 2400, 'correct energy amount')
            assert.equal(event.receiveStatus, false, 'correct receive status')
        })
    })


    describe('handle buy request', async ()=>{
        let time, allow, buyReq, ted, tes, supply, demand, pay
        before(async ()=>{
            time = await exchange.checkTime(25)
            allow = await exchange.allow()
            buyReq = await exchange.buyRequest('BG21S6285Y', 2400, {from: buyer1})
            ted = await exchange.TED()
            tes = await exchange.TES()
            supply = await exchange.supply()
            demand = await exchange.demand()
            pay = await exchange.pay()
        })

        it('handles buy request', async ()=>{
            //success
           assert.equal(allow, false)
            assert.equal(ted, 2400)
            assert.equal(tes, 2400)
            assert.equal(supply, 0)
            assert.equal(demand, 0)
            assert.equal(pay, 157968000000000000)
            console.log(buyReq.logs)
            const event = buyReq.logs[3].args
            assert.equal(event.smartId, 'BG21S6285Y', 'correct smartId')
            assert.equal(event.owner, buyer1, 'correct owner')
            assert.equal(event.microgrid, 1, 'correct microgrid')
            assert.equal(event.energyReq, 0, 'correct energy amount')
            assert.equal(event.receiveStatus, true, 'correct receive status')
        })
    })

    describe('payment', async ()=>{
        let payBefore, payAfter, buyReq
        before(async ()=>{
            payBefore = await exchange.pay()
            buyReq = await exchange.payment({from: buyer1, value: '157968000000000000'})
            payAfter = await exchange.pay()
        })

        it('payment occurs successfully', async ()=>{
            //success
            assert.equal(payBefore, 157968000000000000)
            assert.equal(payAfter, 0)
        })
    })

})