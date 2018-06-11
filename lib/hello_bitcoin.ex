
"""
examples: 
>$ iex -S mix
iex|1|▶▶ HelloBitcoin.getinfo("getconnectioncount")
He{:ok, 8}
iex|2|▶▶ HelloBitcoin.getbitcoinversion            
"bitcoin version: 160000/Satoshi:0.16.0/
iex|11|▶▶ HelloBitcoin.getcurrentblocknumber
407049

"""

defmodule HelloBitcoin do
  def bitcoin_rpc(method, params) do
    with url <- Application.get_env(:hello_bitcoin, :bitcoin_url),
         command <- %{jsonrpc: "1.0", method: method, params: params},
         {:ok, body} <- Poison.encode(command),
         {:ok, response} <- HTTPoison.post(url, body),
         {:ok, metadata} <- Poison.decode(response.body),
         %{"error" => nil, "result" => result} <- metadata do
      {:ok, result}
    else
      %{"error" => reason} -> {:error, reason}
      error -> error
    end
  end


  def getinfo(cmd \\ "getnetworkinfo", params \\ []) do
    case bitcoin_rpc(cmd, params) do
      {:ok, result} -> {:ok, result} 
      {:error, %{"code" => code, "message" => message}} -> {:error, "error: #{code} message: #{message}"}   
    end
  end

  # getinfo() deprecated in Bitcoin Core 0.16 onwards
  def getnetworkinfo, do: getinfo("getnetworkinfo")
  def getblockchaininfo, do: getinfo("getblockchaininfo")
  def getblockhash(index), do: getinfo("getblockhash", [index])
  def getwalletinfo(), do: getinfo("getwalletinfo")
  def getbalance() do
    case getinfo("getwalletinfo") do
      {:ok, resmap} -> resmap["balance"]
      {:error, message} -> message
    end
  end
  
  def getbitcoinversion do
      case getinfo("getnetworkinfo") do
        {:ok, result} -> "bitcoin version: " <> Integer.to_string(result["version"]) <> result["subversion"]
        {:error, message} -> message
      end
  end
  def getconnectioncount do
      {:ok, result} = getinfo("getconnectioncount") 
      result
  end
  def getcurrentblocknumber() do
      {:ok, result} = getinfo("getblockchaininfo")
      result["blocks"]
  end
end

"""  
BITCOIN JSON-RPC API - https://bitcoin.org/en/developer-reference#rpcs

>$ bitcoin-cli -rpcuser=<user> -rpcpassword=<password> help

== Blockchain ==
getbestblockhash
getblock "blockhash" ( verbosity ) 
getblockchaininfo
getblockcount
getblockhash height
getblockheader "hash" ( verbose )
getchaintips
getchaintxstats ( nblocks blockhash )
getdifficulty
getmempoolancestors txid (verbose)
getmempooldescendants txid (verbose)
getmempoolentry txid
getmempoolinfo
getrawmempool ( verbose )
gettxout "txid" n ( include_mempool )
gettxoutproof ["txid",...] ( blockhash )
gettxoutsetinfo
preciousblock "blockhash"
pruneblockchain
savemempool
verifychain ( checklevel nblocks )
verifytxoutproof "proof"

== Control ==
getmemoryinfo ("mode")
help ( "command" )
logging ( <include> <exclude> )
stop
uptime

== Generating ==
generate nblocks ( maxtries )
generatetoaddress nblocks address (maxtries)

== Mining ==
getblocktemplate ( TemplateRequest )
getmininginfo
getnetworkhashps ( nblocks height )
prioritisetransaction <txid> <dummy value> <fee delta>
submitblock "hexdata"  ( "dummy" )

== Network ==
addnode "node" "add|remove|onetry"
clearbanned
disconnectnode "[address]" [nodeid]
getaddednodeinfo ( "node" )
getconnectioncount
getnettotals
getnetworkinfo
getpeerinfo
listbanned
ping
setban "subnet" "add|remove" (bantime) (absolute)
setnetworkactive true|false

== Rawtransactions ==
combinerawtransaction ["hexstring",...]
createrawtransaction [{"txid":"id","vout":n},...] {"address":amount,"data":"hex",...} ( locktime ) ( replaceable )
decoderawtransaction "hexstring" ( iswitness )
decodescript "hexstring"
fundrawtransaction "hexstring" ( options iswitness )
getrawtransaction "txid" ( verbose "blockhash" )
sendrawtransaction "hexstring" ( allowhighfees )
signrawtransaction "hexstring" ( [{"txid":"id","vout":n,"scriptPubKey":"hex","redeemScript":"hex"},...] ["privatekey1",...] sighashtype )

== Util ==
createmultisig nrequired ["key",...]
estimatefee nblocks
estimatesmartfee conf_target ("estimate_mode")
signmessagewithprivkey "privkey" "message"
validateaddress "address"
verifymessage "address" "signature" "message"

== Wallet ==
abandontransaction "txid"
abortrescan
addmultisigaddress nrequired ["key",...] ( "account" "address_type" )
backupwallet "destination"
bumpfee "txid" ( options ) 
dumpprivkey "address"
dumpwallet "filename"
encryptwallet "passphrase"
getaccount "address"
getaccountaddress "account"
getaddressesbyaccount "account"
getbalance ( "account" minconf include_watchonly )
getnewaddress ( "account" "address_type" )
getrawchangeaddress ( "address_type" )
getreceivedbyaccount "account" ( minconf )
getreceivedbyaddress "address" ( minconf )
gettransaction "txid" ( include_watchonly )
getunconfirmedbalance
getwalletinfo
importaddress "address" ( "label" rescan p2sh )
importmulti "requests" ( "options" )
importprivkey "privkey" ( "label" ) ( rescan )
importprunedfunds
importpubkey "pubkey" ( "label" rescan )
importwallet "filename"
keypoolrefill ( newsize )
listaccounts ( minconf include_watchonly)
listaddressgroupings
listlockunspent
listreceivedbyaccount ( minconf include_empty include_watchonly)
listreceivedbyaddress ( minconf include_empty include_watchonly)
listsinceblock ( "blockhash" target_confirmations include_watchonly include_removed )
listtransactions ( "account" count skip include_watchonly)
listunspent ( minconf maxconf  ["addresses",...] [include_unsafe] [query_options])
listwallets
lockunspent unlock ([{"txid":"txid","vout":n},...])
move "fromaccount" "toaccount" amount ( minconf "comment" )
removeprunedfunds "txid"
rescanblockchain ("start_height") ("stop_height")
sendfrom "fromaccount" "toaddress" amount ( minconf "comment" "comment_to" )
sendmany "fromaccount" {"address":amount,...} ( minconf "comment" ["address",...] replaceable conf_target "estimate_mode")
sendtoaddress "address" amount ( "comment" "comment_to" subtractfeefromamount replaceable conf_target "estimate_mode")
setaccount "address" "account"
settxfee amount
signmessage "address" "message"
walletlock
walletpassphrase "passphrase" timeout
walletpassphrasechange "oldpassphrase" "newpassphrase"
"""

