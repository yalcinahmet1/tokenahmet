// Welcome to the Leo Playground. Leo is a formally verified programming
// language built for writing private applications. That means your
// programmes will create a proof of their correct execution, and this
// proof can be added to the Aleo chain directly. Here you can try the
// Leo language without downloading and installing the latest release on
// your computer. If you want to install it, you can read the instructions
// https://developer.aleo.org/leo/installation
//
// So, let's get started!
//
// 1. You can try this transition function by running: 
// leo run main 1u32 2u32
// 2. Below the 'STDIN/STDOUT' panel you will be able to see some details
// of your run.
//
// Congratulations! You've just run your first Leo program.
//
// Please refer to the Examples dropdown for more examples and exercises
// on how Leo works.
//
// ______________________________________________________________________
// Main function
program ahmetyalcintoken.aleo{

  mapping account:address => u64;

  record token{
    owner: address,
    amount: u64,
  }

  transition mint_public(public receiver:address, public amount:u64){
    return then finalize(receiver,amount);
  }

  finalize mint_public(public receiver:address, public amount:u64){
    let receiver_amount: u64 = Mapping::get_or_use(account,receiver , 0u64);
    Mapping::set(account,receiver,receiver_amount + amount);
  }

  transition mint_private(receiver:address, amount:u64) -> token {
    return token{
      owner: receiver,
      amount: amount,
    };
  }

  transition transfer_public(public receiver:address, public amount:u64){

    return then finalize(self.caller, receiver, amount);
  }

  finalize transfer_public(public sender:address, public receiver:address, public amount:u64){
    let sender_amount:u64 = Mapping::get_or_use(account,sender , 0u64);
    Mapping::set(account, sender, sender_amount-amount);

    let receiver_amount:u64 = Mapping::get_or_use(account,receiver , 0u64);
    Mapping::set(account, receiver, receiver_amount + amount);
  }

  transition transfer_private(sender:token, receiver:address, amount:u64) -> (token, token){
    let difference:u64 = sender.amount - amount;

    let remaining: token = token {
      owner:sender.owner,
      amount:difference
    };

    let transferred:token = token {
      owner:receiver,
      amount:amount
    };

    return(remaining, transferred);
  }

  transition transfer_private_to_public(sender:token, public receiver:address, public amount:u64) -> token{
    let difference:u64 = sender.amount - amount;

    let remaining:token = token{
      owner:sender.owner,
      amount:difference
    };

    return remaining then finalize(receiver, amount);
  }

  finalize transfer_private_to_public(public receiver:address, public amount:u64){
    let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64);
    Mapping::set(account, receiver, receiver_amount + amount);
  }

  transition transfer_public_to_private(receiver:address, amount:u64) ->token {
    let transferred: token =token{
      owner:receiver,
      amount: amount
    };

    return transferred then finalize(self.caller, amount);
  }

  finalize transfer_public_to_private(public sender:address, public amount:u64){
    let sender_amount:u64 = Mapping::get_or_use(account, sender, 0u64);
    Mapping::set(account, sender, sender_amount - amount);
  }

 


}
