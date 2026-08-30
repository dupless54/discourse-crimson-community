import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import RouteTemplate from "ember-route-template";
import { ajax } from "discourse/lib/ajax";
import DButton from "discourse/ui-kit/d-button";
import DUserInfo from "discourse/ui-kit/d-user-info";
import dFormatDate from "discourse/ui-kit/helpers/d-format-date";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

class CrimsonCommunityPage extends Component {
  @tracked snapshot = this.args.initialSnapshot;
  @tracked visitors = this.args.initialSnapshot?.profile_visitors;
  @tracked query = "";
  @tracked isRefreshing = false;
  @tracked refreshFailed = false;
  @tracked isRefreshingVisitors = false;
  @tracked visitorRefreshFailed = false;

  get users() {
    return Array.isArray(this.snapshot?.users) ? this.snapshot.users : [];
  }

  get visitorUsers() {
    return Array.isArray(this.visitors?.users) ? this.visitors.users : [];
  }

  get visitorsEnabled() {
    return this.visitors?.enabled === true;
  }

  get visitorsDisabled() {
    return this.visitors?.enabled === false;
  }

  get visitorsUnavailable() {
    return Boolean(this.visitors?.unavailable);
  }

  get normalizedQuery() {
    return this.query.trim().toLowerCase();
  }

  get hasQuery() {
    return this.normalizedQuery.length > 0;
  }

  get filteredUsers() {
    const query = this.normalizedQuery;

    if (!query) {
      return this.users;
    }

    return this.users.filter((user) => {
      const username = String(user?.username || "").toLowerCase();
      const name = String(user?.name || "").toLowerCase();

      return username.includes(query) || name.includes(query);
    });
  }

  @action
  updateQuery(event) {
    this.query = event.target.value;
  }

  @action
  clearQuery() {
    this.query = "";
  }

  @action
  async refreshSnapshot() {
    if (this.isRefreshing) {
      return;
    }

    this.isRefreshing = true;
    this.refreshFailed = false;

    try {
      this.snapshot = await ajax("/crimson-community/online.json");
    } catch {
      this.refreshFailed = true;
    } finally {
      this.isRefreshing = false;
    }
  }

  @action
  async refreshVisitors() {
    if (this.isRefreshingVisitors) {
      return;
    }

    this.isRefreshingVisitors = true;
    this.visitorRefreshFailed = false;

    try {
      this.visitors = await ajax("/crimson-community/profile-visits.json");
    } catch {
      this.visitorRefreshFailed = true;
    } finally {
      this.isRefreshingVisitors = false;
    }
  }

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
            <strong>{{this.snapshot.total_count}}</strong>
            <span>{{i18n "crimson_community.page.online_now"}}</span>
          </div>
        </article>

        <article class="crimson-community-summary__item">
          <span class="crimson-community-summary__icon" aria-hidden="true">
            {{dIcon "users"}}
          </span>
          <div>
            <strong>{{this.snapshot.count}}</strong>
            <span>{{i18n "crimson_community.page.members_shown"}}</span>
          </div>
        </article>

        <article class="crimson-community-summary__item">
          <span class="crimson-community-summary__icon" aria-hidden="true">
            {{dIcon "clock"}}
          </span>
          <div>
            <strong>{{this.snapshot.window_minutes}}</strong>
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

      {{#if this.refreshFailed}}
        <div
          class="crimson-community-page__status crimson-community-page__status--error"
          role="alert"
          data-test-community-refresh-error
        >
          {{dIcon "circle-exclamation"}}
          <span>{{i18n "crimson_community.page.refresh_error"}}</span>
        </div>
      {{/if}}

      <section
        class="crimson-community-visitors"
        aria-labelledby="crimson-community-visitors-title"
        data-test-community-visitors
      >
        <header class="crimson-community-visitors__header">
          <div>
            <h2 id="crimson-community-visitors-title">
              {{i18n "crimson_community.page.visitors_title"}}
            </h2>
            <p>{{i18n "crimson_community.page.visitors_description"}}</p>
          </div>

          {{#if this.visitorsEnabled}}
            <div class="crimson-community-visitors__header-actions">
              <span class="crimson-community-visitors__count">
                {{this.visitors.count}}
              </span>
              <DButton
                @action={{this.refreshVisitors}}
                @icon="arrows-rotate"
                @label="crimson_community.page.refresh_visitors"
                @isLoading={{this.isRefreshingVisitors}}
                class="btn-default"
                data-test-community-visitors-refresh
              />
            </div>
          {{/if}}
        </header>

        {{#if this.visitorRefreshFailed}}
          <div
            class="crimson-community-visitors__status crimson-community-visitors__status--error"
            role="alert"
            data-test-community-visitors-refresh-error
          >
            {{dIcon "circle-exclamation"}}
            <span>{{i18n "crimson_community.page.visitors_refresh_error"}}</span>
          </div>
        {{/if}}

        {{#if this.visitorsUnavailable}}
          <div class="crimson-community-visitors__empty" data-test-community-visitors-unavailable>
            <span class="crimson-community-visitors__empty-icon" aria-hidden="true">
              {{dIcon "circle-exclamation"}}
            </span>
            <div>
              <strong>{{i18n "crimson_community.page.visitors_unavailable_title"}}</strong>
              <p>{{i18n "crimson_community.page.visitors_unavailable_description"}}</p>
              <DButton
                @action={{this.refreshVisitors}}
                @icon="arrows-rotate"
                @label="crimson_community.page.retry_visitors"
                @isLoading={{this.isRefreshingVisitors}}
                class="btn-default"
                data-test-community-visitors-retry
              />
            </div>
          </div>
        {{else if this.visitorsDisabled}}
          <div class="crimson-community-visitors__empty" data-test-community-visitors-disabled>
            <span class="crimson-community-visitors__empty-icon" aria-hidden="true">
              {{dIcon "eye-slash"}}
            </span>
            <div>
              <strong>{{i18n "crimson_community.page.visitors_disabled_title"}}</strong>
              <p>{{i18n "crimson_community.page.visitors_disabled_description"}}</p>
            </div>
          </div>
        {{else if this.visitorUsers.length}}
          <div class="crimson-community-visitors__list">
            {{#each this.visitorUsers as |visitor|}}
              <article class="crimson-community-visitor-row">
                <DUserInfo @user={{visitor}} @headingLevel={{3}} @size="large" />
                <span class="crimson-community-visitor-row__time">
                  {{dIcon "clock"}}
                  {{dFormatDate visitor.last_visited_at format="tiny"}}
                </span>
              </article>
            {{/each}}
          </div>

          <footer class="crimson-community-visitors__footer">
            {{dIcon "circle-info"}}
            <span>
              {{i18n
                "crimson_community.page.visitors_retention"
                count=this.visitors.retention_days
              }}
            </span>
          </footer>
        {{else}}
          <div class="crimson-community-visitors__empty" data-test-community-visitors-empty>
            <span class="crimson-community-visitors__empty-icon" aria-hidden="true">
              {{dIcon "users"}}
            </span>
            <div>
              <strong>{{i18n "crimson_community.page.visitors_empty_title"}}</strong>
              <p>{{i18n "crimson_community.page.visitors_empty_description"}}</p>
            </div>
          </div>
        {{/if}}
      </section>

      {{#if this.users.length}}
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
            <span class="crimson-community-members__count">
              {{this.filteredUsers.length}}
            </span>
          </header>

          <div class="crimson-community-members__toolbar">
            <div class="crimson-community-members__search-field">
              <label for="crimson-community-member-search">
                {{i18n "crimson_community.page.search_label"}}
              </label>
              <input
                id="crimson-community-member-search"
                class="crimson-community-members__search-input"
                type="search"
                value={{this.query}}
                placeholder={{i18n "crimson_community.page.search_placeholder"}}
                autocomplete="off"
                data-test-community-search
                {{on "input" this.updateQuery}}
              />
            </div>

            <div class="crimson-community-members__actions">
              {{#if this.hasQuery}}
                <DButton
                  @action={{this.clearQuery}}
                  @icon="circle-xmark"
                  @label="crimson_community.page.clear_search"
                  class="btn-default"
                  data-test-community-search-clear
                />
              {{/if}}

              <DButton
                @action={{this.refreshSnapshot}}
                @icon="arrows-rotate"
                @label="crimson_community.page.refresh"
                @isLoading={{this.isRefreshing}}
                class="btn-default"
                data-test-community-refresh
              />
            </div>
          </div>

          {{#if this.filteredUsers.length}}
            <div class="crimson-community-members__list">
              {{#each this.filteredUsers as |user|}}
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
          {{else}}
            <div
              class="crimson-community-search-empty"
              data-test-community-search-empty
            >
              <span class="crimson-community-search-empty__icon" aria-hidden="true">
                {{dIcon "magnifying-glass"}}
              </span>
              <div>
                <strong>{{i18n "crimson_community.page.search_empty_title"}}</strong>
                <p>{{i18n "crimson_community.page.search_empty_description"}}</p>
              </div>
            </div>
          {{/if}}

          {{#if this.snapshot.remaining_count}}
            <div class="crimson-community-members__more" role="status">
              {{dIcon "circle-info"}}
              <span>
                {{i18n
                  "crimson_community.page.more_online"
                  count=this.snapshot.remaining_count
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
          <div class="crimson-community-empty__actions">
            <DButton
              @action={{this.refreshSnapshot}}
              @icon="arrows-rotate"
              @label="crimson_community.page.refresh"
              @isLoading={{this.isRefreshing}}
              class="btn-default"
              data-test-community-refresh
            />
            <a class="btn btn-default" href="/u">
              {{dIcon "users"}}
              <span>{{i18n "crimson_community.page.all_members"}}</span>
            </a>
          </div>
        </section>
      {{/if}}
    </div>
  </template>
}

export default RouteTemplate(
  <template>
    <CrimsonCommunityPage @initialSnapshot={{@model}} />
  </template>,
);
