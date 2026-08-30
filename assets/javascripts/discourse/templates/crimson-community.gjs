import RouteTemplate from "ember-route-template";
import DUserInfo from "discourse/ui-kit/d-user-info";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
  <template>
    <div class="wrap crimson-community-page">
      <header class="crimson-community-page__header">
        <div class="crimson-community-page__heading">
          <div class="crimson-community-page__live-label">
            <span class="crimson-community-presence-dot" aria-hidden="true"></span>
            <span>{{i18n "crimson_community.page.live_label"}}</span>
          </div>

          <h1 id="crimson-community-title">
            {{i18n "crimson_community.page.title"}}
          </h1>
          <p>{{i18n "crimson_community.page.description"}}</p>
        </div>

        <a class="btn btn-default crimson-community-page__directory-link" href="/u">
          {{dIcon "users"}}
          <span>{{i18n "crimson_community.page.all_members"}}</span>
        </a>
      </header>

      <section
        class="crimson-community-summary"
        aria-label={{i18n "crimson_community.page.summary_label"}}
      >
        <article class="crimson-community-summary__item">
          <span class="crimson-community-summary__icon" aria-hidden="true">
            {{dIcon "circle-check"}}
          </span>
          <div>
            <strong>{{@model.total_count}}</strong>
            <span>{{i18n "crimson_community.page.online_now"}}</span>
          </div>
        </article>

        <article class="crimson-community-summary__item">
          <span class="crimson-community-summary__icon" aria-hidden="true">
            {{dIcon "users"}}
          </span>
          <div>
            <strong>{{@model.count}}</strong>
            <span>{{i18n "crimson_community.page.members_shown"}}</span>
          </div>
        </article>

        <article class="crimson-community-summary__item">
          <span class="crimson-community-summary__icon" aria-hidden="true">
            {{dIcon "clock"}}
          </span>
          <div>
            <strong>{{@model.window_minutes}}</strong>
            <span>{{i18n "crimson_community.page.minute_window"}}</span>
          </div>
        </article>
      </section>

      <aside class="crimson-community-privacy-note">
        <span class="crimson-community-privacy-note__icon" aria-hidden="true">
          {{dIcon "eye-slash"}}
        </span>
        <div>
          <strong>{{i18n "crimson_community.page.privacy_title"}}</strong>
          <p>{{i18n "crimson_community.page.privacy_description"}}</p>
        </div>
      </aside>

      {{#if @model.users.length}}
        <section
          class="crimson-community-members"
          aria-labelledby="crimson-community-online-title"
        >
          <header class="crimson-community-members__header">
            <div>
              <h2 id="crimson-community-online-title">
                {{i18n "crimson_community.page.online_members"}}
              </h2>
              <p>{{i18n "crimson_community.page.online_members_description"}}</p>
            </div>
            <span class="crimson-community-members__count">{{@model.count}}</span>
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

          {{#if @model.remaining_count}}
            <div class="crimson-community-members__more" role="status">
              {{dIcon "circle-info"}}
              <span>
                {{i18n
                  "crimson_community.page.more_online"
                  count=@model.remaining_count
                }}
              </span>
            </div>
          {{/if}}
        </section>
      {{else}}
        <section class="crimson-community-empty">
          <span class="crimson-community-empty__icon" aria-hidden="true">
            {{dIcon "users"}}
          </span>
          <h2>{{i18n "crimson_community.page.empty_title"}}</h2>
          <p>{{i18n "crimson_community.page.empty_description"}}</p>
          <a class="btn btn-default" href="/u">
            {{dIcon "users"}}
            <span>{{i18n "crimson_community.page.all_members"}}</span>
          </a>
        </section>
      {{/if}}
    </div>
  </template>,
);
