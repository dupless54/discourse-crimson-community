import RouteTemplate from "ember-route-template";
import DUserInfo from "discourse/ui-kit/d-user-info";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
  <template>
    <div class="wrap crimson-community-page">
      <header class="crimson-community-page__header">
        <div>
          <p class="crimson-community-page__eyebrow">
            {{i18n "crimson_community.page.eyebrow"}}
          </p>
          <h1 id="crimson-community-title">
            {{i18n "crimson_community.page.title"}}
          </h1>
          <p>{{i18n "crimson_community.page.description"}}</p>
        </div>

        <a class="btn btn-default" href="/u">
          {{dIcon "users"}}
          <span>{{i18n "crimson_community.page.all_members"}}</span>
        </a>
      </header>

      <section
        class="crimson-community-summary"
        aria-label={{i18n "crimson_community.page.summary_label"}}
      >
        <div class="crimson-community-summary__item">
          <span class="crimson-community-presence-dot" aria-hidden="true"></span>
          <strong>{{@model.count}}</strong>
          <span>{{i18n "crimson_community.page.online_now"}}</span>
        </div>
        <div class="crimson-community-summary__item">
          <strong>{{@model.window_minutes}}</strong>
          <span>{{i18n "crimson_community.page.minute_window"}}</span>
        </div>
      </section>

      {{#if @model.users.length}}
        <section
          class="crimson-community-members"
          aria-labelledby="crimson-community-online-title"
        >
          <header class="crimson-community-members__header">
            <h2 id="crimson-community-online-title">
              {{i18n "crimson_community.page.online_members"}}
            </h2>
            <span>{{@model.count}}</span>
          </header>

          <div class="crimson-community-members__list">
            {{#each @model.users as |user|}}
              <article class="crimson-community-member-row">
                <DUserInfo @user={{user}} @headingLevel={{3}} @size="large" />
                <span class="crimson-community-member-row__state">
                  <span
                    class="crimson-community-presence-dot"
                    aria-hidden="true"
                  ></span>
                  {{i18n "crimson_community.page.online"}}
                </span>
              </article>
            {{/each}}
          </div>
        </section>
      {{else}}
        <section class="crimson-community-empty">
          <span class="crimson-community-empty__icon" aria-hidden="true">
            {{dIcon "users"}}
          </span>
          <h2>{{i18n "crimson_community.page.empty_title"}}</h2>
          <p>{{i18n "crimson_community.page.empty_description"}}</p>
        </section>
      {{/if}}
    </div>
  </template>,
);
