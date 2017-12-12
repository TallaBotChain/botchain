import { expect } from 'chai'
import asyncReturnErr from './asyncReturnErr'

export default async (asyncFn) => {
  const err = await asyncReturnErr(asyncFn)
  expect(err.message.search('revert') > -1).to.equal(true)
}
