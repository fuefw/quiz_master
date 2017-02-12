<template>
  <div class="question-form" v-if="categoryOptions">
    <banner :backgroundImage="backgroundImage()">
      <h1 class="banner__main-title" slot="main-title" v-if="creating">
        Adding a Question to the Archives
      </h1>
      <h1 class="banner__main-title" slot="main-title" v-else>
        Nothing is perfect the first time.
      </h1>
      <h3 class="banner__sub-title" slot="sub-title" v-if="creating">
        We appreciate your contribution.  Please enter your data below.
      </h3>
      <h3 class="banner__sub-title" slot="sub-title" v-else>
        Thanks for taking the time to refine this question.
      </h3>
    </banner>
    <div class="question-form__inner">

      <h1 class="question-form__main-title">Question Info</h1>
      <form class="form">
        <div class="question__basic-info">
          <div class="form__row">
            <label for="name" class="form__label">
              Give your question a name:
            </label>
            <input type="text" name="name" v-model="name" class="form__text-input" required="true" placeholder="Name">
          </div>

          <div class="form__row">
            <label for="description" class="form__label">
              A quick description of your question:
            </label>
            <input type="text" name="description" v-model="description" class="form__text-input" required="true" placeholder="Description">
          </div>

          <div class="form__row">
            <label for="answer" class="form__label">
              The answer to your question:
            </label>
            <input type="text" name="answer" v-model="answer" class="form__text-input" required="true" placeholder="Answer">
          </div>

          <div class="form__row">
            <label for="category_id" class="form__label">Add a category: </label>
            <multiselect
                class="form__select-input"
                v-model="selectedCategory"
                :options="categoryOptions"
                placeholder="Choose a category..."
                label="name"
                track-by="name"
                >
            </multiselect>
          </div>
        </div>

        <h1 class="question-form__main-title">Question Content</h1>
        <div class="markdown-editor-container">
          <markdown-editor
            :inputMarkdown="content"
            v-on:updateContent="setContent"
            >
          </markdown-editor>

          <markdown-helper/>
        </div>

        <div class="form__row">
          <a class="btn form__submit-btn" v-on:click="createQuestion" v-if="creating">
            Submit Question
          </a>
          <a class="btn form__submit-btn" v-on:click="updateQuestion" v-else>
            Update Question
          </a>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import api from 'services/api';
import MarkdownEditor from 'components/MarkdownEditor';
import MarkdownHelper from 'components/MarkdownHelper';
import Multiselect from 'vue-multiselect';
import Banner from 'components/Banner';

export default {
  name: 'question-list',
  components: {
    MarkdownEditor,
    MarkdownHelper,
    Multiselect,
    Banner,
  },
  created() {
    this.fetchCategories();
  },
  mounted() {
    console.log("mounted");
    if (this.creating) {
      this.clearQuestionFields();
    } else {
      this.id = this.$route.params.id;
      this.getQuestion(this.id);
    }
  },
  beforeRouteLeave(route, redirect, next) {
    this.clearQuestionFields();
    next();
  },
  data() {
    return {
      content: '# hello',
      answer: '',
      name: '',
      category_id: null,
      image_url: '',
      description: '',
      selectedCategory: {},
      categoryOptions: null,
    };
  },
  methods: {
    createQuestion() {
      api.createQuestion(this.question).then(
        (resp) => {
          this.$router.push(`/question/${resp.data.question.id}`);
        },
        () => {
          console.log("FAILED");
        },
      );
    },
    updateQuestion() {
      api.updateQuestion(this.question).then(
        () => {
          this.$router.push("/");
        },
        () => {
          console.log("FAILED");
        },
      );
    },
    setContent(newContent) {
      this.content = newContent;
    },
    fetchCategories() {
      api.getCategories().then(
        (resp) => {
          this.categoryOptions = resp.data.categories;
        },
        () => {
          console.log("FAILED");
        },
      );
    },
    backgroundImage() {
      if (this.creating) {
        return "/static/categories/new_question.jpg";
      }
      return this.image_url;
    },
    getQuestion(id) {
      api.getQuestion(id).then(
        (resp) => {
          const question = resp.data.question;
          this.name = question.name;
          this.content = question.content;
          this.answer = question.answer;
          this.description = question.description;
          this.category_id = question.category.id;
          this.image_url = question.category.image_url;
          this.selectedCategory = this.categoryOptions.find(cat => cat.id === question.category.id);
        },
      );
    },
    clearQuestionFields() {
      this.name = null;
      this.content = '# hello';
      this.answer = null;
      this.description = '';
      this.category_id = null;
      this.image_url = null;
      this.selectedCategory = null;
    },
  },
  computed: {
    question() {
      return {
        id: this.id,
        content: this.content,
        answer: this.answer,
        name: this.name,
        category_id: this.selectedCategory.id,
        description: this.description,
      };
    },
    creating() {
      return this.$route.name === 'newQuestion';
    },
  },
};
</script>

<style lang="scss">
@import "src/assets/styles/base/mixins";
@import "src/assets/styles/base/variables";

.question-form {
  flex: 1;
  flex-direction: column;
  justify-content: center;
  margin: 0 auto 4rem auto;
}

.question-form__inner {
  @include flex-container;
  margin: auto;
}

.markdown-editor-container {
  margin-top: 0;
}

.question-form__main-title {
  margin-bottom: 0;
}

.question__basic-info {
  padding: 1rem 0 2.5rem;
  display: flex;
  flex-direction: column;
  background: #f8f8f8;
  padding: 1.4rem;
  color: #555;
  border-left: 6px solid $action-color;
}

</style>