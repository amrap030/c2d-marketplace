import Web3 from "web3";
import abi from "../abi/Marketplace.json";
import { MARKETPLACE_ADDRESS } from "@/config";

const web3ProviderUrl = "ws://127.0.0.1:8545";
const web3 = new Web3(new Web3.providers.WebsocketProvider(web3ProviderUrl));

const compiledContract = new web3.eth.Contract(
  abi.abi as any,
  MARKETPLACE_ADDRESS,
);

const callbacks = {};
const running = true;
const pollingInterval = 1000;
let timeoutId = null;

export const listen = () => consumeEvents();

export const on = async (eventName, callback) => {
  if (compiledContract.events[eventName]) {
    callbacks[eventName] = callback;
  } else {
    throw new Error(
      `The "${eventName}" event does not exist in the configured contract.`,
    );
  }
};

const poll = async (fn, time) => {
  if (running) {
    await fn();
    timeoutId = setTimeout(() => poll(fn, time), time);
  } else {
    clearTimeout(timeoutId);
  }
};

const consumeEvents = async () => {
  let fromBlock = await web3.eth.getBlockNumber();

  poll(async () => {
    try {
      const latestBlock = await web3.eth.getBlockNumber();

      const events = (await getEvents(
        compiledContract,
        latestBlock,
        latestBlock,
      )) as any;

      if (fromBlock == latestBlock) {
        return;
      }

      events.forEach(async eventLog => {
        const eventName = eventLog.event;

        try {
          if (callbacks[eventName]) {
            await callbacks[eventName](eventLog);
          }
        } catch (processingError) {
          console.log(processingError);
        }
      });

      fromBlock = latestBlock;
    } catch (eventsError) {
      console.log(eventsError);
    }
  }, pollingInterval);
};

const getEvents = (contract, fromBlock, toBlock) =>
  new Promise((resolve, reject) => {
    contract.getPastEvents(
      "allEvents",
      { fromBlock, toBlock },
      (err, eventLogs) => {
        if (err) {
          return reject(err);
        }

        resolve(eventLogs);
      },
    );
  });

export default { listen, on };
