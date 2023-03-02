export const delay = (time: number) => {
  return new Promise(resolve => setTimeout(resolve, time));
};

export const removeDuplicateStrings = (array: any[]) => {
  const uniqueValues = [];
  const seenMap = {} as any;

  for (const item of array) {
    if (seenMap[item]) continue;
    seenMap[item] = true;
    uniqueValues.push(item);
  }

  return uniqueValues;
};

export const removeDuplicates = (array: any[]) => {
  // Turn our array into a Set, which can only contain
  // unique values, and then make an array from that set.
  return [...new Set(array)];
};

/**
 * Returns the provided URLs search parameters
 * as a set of key-value pairs.
 */
export const getURLParameters = (url: string) => {
  const { searchParams } = new URL(url);
  return Object.fromEntries(searchParams);
};

export const isObjectEmpty = (object: object) => {
  if (object.constructor !== Object) return false;
  // Iterates over the keys of an object, if
  // any exist, return false.
  for (_ in object) return false;
  return true;
};

export const reverseString = (string: string) => {
  let reversedString = "";

  for (let i = string.length - 1; i >= 0; i--) reversedString += string[i];

  return reversedString;
};

export const getRandomHexColor = () => {
  const randomValue = Math.floor(Math.random() * 0xffffff);
  const hexValue = randomValue.toString(16);
  return hexValue.padStart(6, "0");
};
