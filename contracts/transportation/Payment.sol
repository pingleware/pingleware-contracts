// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;


contract Payment {
    mapping(address => uint) accbalance;

    event PaymentMessage(string message);
    event PaymentInfo(string message, uint amount);

    function makePayment(address _from, address _to, uint _amount )
        public
        returns(bool, uint)
    {
        emit PaymentInfo('amount is:',_amount);

        if(_amount<=0 && accbalance[_from]<_amount) {
            emit PaymentMessage('insufficient funds');
            return (false, 0);
        }

        accbalance[_from] -= _amount;
        accbalance[_to] += _amount;
        emit PaymentMessage('Successful payment');
        return (true, _amount);
    }
}