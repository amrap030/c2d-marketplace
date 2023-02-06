import { computed, defineComponent, ref } from "vue";
import { RouterLink } from "vue-router";
import type { Indexable } from "@types";

const ButtonColor: Indexable<string> = {
  primary: "bg-blue text-creme border border-blue hover:opacity-90",
  secondary: "bg-creme text-neutral-900 border border-creme hover:opacity-90",
  outline:
    "bg-neutral-900 text-current border border-transparent hover:opacity-80",
  transparent:
    "bg-transparent text-neutral-50 border-transparent hover:opacity-80",
  gray: "bg-neutral-700 text-neutral-400 border-neutral-700 hover:opacity-90",
  blur: "bg-neutral-900/50 backdrop-blur-sm text-neutral-200 hover:opacity-90",
  disabled: "bg-neutral-800 text-neutral-400/50 border-neutral-800",
};

const ButtonSizeIcon: Indexable<string> = {
  xs: "w-6 h-6 text-xs",
  sm: "w-8 h-8 text-sm",
  md: "w-10 h-10 text-base",
  lg: "w-12 h-12 text-lg",
};

const ButtonSizeDefault: Indexable<string> = {
  xs: "text-xs",
  sm: "text-sm",
  md: "text-md",
  lg: "text-lg",
};

const ButtonSpacing: Indexable<string> = {
  xs: "py-1 px-2 space-x-2",
  sm: "py-2 px-4 space-x-2",
  md: "py-3 px-6 space-x-2",
  lg: "py-4 px-8 space-x-2",
};

const ButtonRounded: Indexable<string> = {
  none: "rounded-none",
  base: "rounded-xl",
  full: "rounded-full",
};

export default defineComponent({
  emits: ["click"],
  props: {
    type: {
      type: String,
      default: "button",
    },
    color: {
      type: String as () =>
        | "primary"
        | "secondary"
        | "outline"
        | "gray"
        | "blur"
        | "transparent",
      default: "primary",
    },
    rounded: {
      type: String as () => "full" | "base" | "none",
      default: "base",
    },
    size: {
      type: String as () => "xxs" | "xs" | "sm" | "md" | "lg",
      default: "md",
    },
    fullWidth: {
      type: Boolean,
      default: false,
    },
    onlyIcon: {
      type: Boolean,
      default: false,
    },
    to: {
      type: String,
      default: null,
    },
    href: {
      type: String,
      default: null,
    },
    loading: {
      type: Boolean,
      default: false,
    },
    disabled: {
      type: Boolean,
      default: false,
    },
  },
  setup(props, { emit, slots }) {
    const hover = ref(false);

    const classesButton = computed(() => [
      `relative inline-flex items-center text-center transition font-semibold duration-200 tracking-wide`,
      ButtonRounded[props.rounded],
      ButtonColor[props.disabled ? "disabled" : props.color],
      !props.onlyIcon && ButtonSpacing[props.size],
      props.onlyIcon
        ? ButtonSizeIcon[props.size]
        : ButtonSizeDefault[props.size],
      props.onlyIcon ? "justify-center" : "justify-center",
      props.fullWidth && "w-full",
      !(props.disabled || props.loading)
        ? "cursor-pointer active:scale-[97%]"
        : "cursor-default",
    ]);

    const classesLoader = computed(() => [
      `absolute inset-0 w-full h-full flex items-center justify-center transition duration-200`,
      props.loading ? "block" : "hidden",
      ButtonRounded[props.rounded],
      ButtonColor[props.color],
    ]);

    const LoadingNode = () => (
      <span class={classesLoader.value}>
        <span></span>
      </span>
    );

    const isRouterLink = !!props.to;
    const isAnchorLink = !!props.href;
    const isRouterOrAnchorLink = isRouterLink || isAnchorLink;

    const Tag: any = isAnchorLink ? "a" : isRouterLink ? RouterLink : "button";

    const onClick = (e: Event) => {
      if (!(props.disabled || props.loading)) {
        emit("click", e);
      }
    };

    return () => (
      <Tag
        hover={hover.value}
        type={!isRouterOrAnchorLink ? props.type : undefined}
        aria-disabled={props.disabled === true ? true : undefined}
        target={isAnchorLink ? "_blank" : undefined}
        to={isRouterLink ? props.to : undefined}
        href={isRouterOrAnchorLink ? props.href || props.to : undefined}
        class={classesButton.value}
        onMouseenter={() => (hover.value = true)}
        onMouseleave={() => (hover.value = false)}
        onClick={onClick}
      >
        {slots.default && slots.default()}
        {props.loading && <LoadingNode />}
      </Tag>
    );
  },
});
