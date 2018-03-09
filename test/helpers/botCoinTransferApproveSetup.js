export default async function botCoinTransferApproveSetup (
  initialBotCoinBalance,
  botCoin,
  registryAddress,
  transferFromAddress,
  amount
) {
  await botCoin.transfer(transferFromAddress, initialBotCoinBalance)
  await botCoin.approve(registryAddress, initialBotCoinBalance, { from: transferFromAddress })
}
