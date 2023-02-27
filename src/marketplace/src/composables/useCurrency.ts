import { inject, ref } from "vue";
import type { Ref } from "vue";
import { useQuery } from "@vue/apollo-composable";
import { TOKEN_HOUR_DATAS } from "@/graphql/currency";
import type { ApolloError } from "@apollo/client";
import { clientIdUniswapV3 } from "@/graphql";

export const CURRENCY_CONTEXT = Symbol();

export interface UseCurrency {
  maticToUsd: (matic: string | number, fractionDigits?: number) => string;
  usdToMatic: (matic: string | number, fractionDigits?: number) => string;
  maticPrice: Ref<string>;
  error: Ref<ApolloError | null>;
}

export function createCurrency(): UseCurrency {
  const defaultFractionDigits = 2;
  const maticPrice = ref("0.00");

  const { result, error, onResult } = useQuery(TOKEN_HOUR_DATAS, null, {
    clientId: clientIdUniswapV3,
  });

  onResult(() => {
    maticPrice.value = result.value?.tokenHourDatas[0].close;
  });

  const maticToUsd = function (
    matic: string | number,
    fractionDigits = defaultFractionDigits,
  ) {
    return (Number(matic) * Number(maticPrice.value)).toFixed(fractionDigits);
  };

  const usdToMatic = function (
    usd: string | number,
    fractionDigits = defaultFractionDigits,
  ) {
    return (Number(usd) / Number(maticPrice.value)).toFixed(fractionDigits);
  };

  return {
    maticToUsd,
    usdToMatic,
    maticPrice,
    error,
  };
}

export function useCurrency(): UseCurrency {
  const context = inject(CURRENCY_CONTEXT) as UseCurrency;

  if (!context) {
    throw new Error("useCurrency must be used with createCurrency");
  }

  return context;
}
