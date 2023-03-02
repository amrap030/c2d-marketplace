import { computed, defineComponent } from "vue";
import AppLoader from "@/components/app/AppLoader.vue";
import { highlight, languages } from "prismjs";

const preClass = [
  "flex min-h-full text-xs md:text-sm language-javascript w-full",
];

const numClass = [
  "flex-none hidden py-4 pr-4 text-right text-white text-opacity-50 select-none md:block",
];

const loaderClass = [
  "flex justify-center py-4 text-white w-full -translate-x-[25px]",
];
const codeClass = [
  "relative flex-auto block px-4 pt-4 pb-4 overflow-auto text-white",
];

export default defineComponent({
  props: {
    loading: {
      type: Boolean,
      default: false,
    },
    code: {
      type: String,
      required: true,
    },
  },
  setup(props) {
    const renderedCode = computed(() =>
      highlight(props.code, languages.js, "js"),
    );

    return () => (
      <pre class={preClass}>
        <div
          class={numClass}
          style="width:50px"
          id="rowNumbers"
          ariaHidden="true"
        >
          {props.code &&
            [...props.code.match(/\n/g)!, "\n"].map((_, index) => (
              <span>{index + 1 + "\n"}</span>
            ))}
        </div>
        {props.loading ? (
          <div class={loaderClass}>
            <AppLoader />
          </div>
        ) : (
          <code
            class={props.code ? codeClass : loaderClass}
            innerHTML={props.code ? renderedCode.value : "No data"}
          ></code>
        )}
      </pre>
    );
  },
});
