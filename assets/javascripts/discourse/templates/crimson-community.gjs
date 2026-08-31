import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action, get } from "@ember/object";
import { service } from "@ember/service";
import RouteTemplate from "ember-route-template";
import { ajax } from "discourse/lib/ajax";
import DButton from "discourse/ui-kit/d-button";
import DUserInfo from "discourse/ui-kit/d-user-info";
import dFormatDate from "discourse/ui-kit/helpers/d-format-date";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

const VISITOR_PREVIEW_LIMIT = 6;

class CrimsonCommunityPage extends Component {
  @service currentUser;

  @tracked snapshot = this.args.initialSnapshot;
  @tracked visitors = this.args.initialSnapshot?.profile_visitors;
  @tracked query = "";
  @tracked sortMode = "recent";
  @tracked density = "comfortable";
  @tracked isRefreshing = false;
  @tracked refreshFailed = false;
  @tracked isRefreshingVisitors = false;
  @tracked visitorRefreshFailed = false;
  @tracked showAllVisitors = false;
  @tracked dashboardRefreshOutcome = null;

  get users() {
    return Array.isArray(this.snapshot?.users) ? this.snapshot.users : [];
  }

  get visitorUsers() {
    return Array.isArray(this.visitors?.users) ? this.visitors.users : [];
  }

  get visibleVisitorUsers() {
    if (this.showAllVisitors) {
      return this.visitorUsers;
    }

    return this.visitorUsers.slice(0, VISITOR_PREVIEW_LIMIT);
  }

  get hasMoreVisitorUsers() {
    return this.visitorUsers.length > VISITOR_PREVIEW_LIMIT;
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

  get isRefreshingDashboard() {
    return this.isRefreshing || this.isRefreshingVisitors;
  }

  get dashboardRefreshPartial() {
    return this.dashboardRefreshOutcome === "partial";
  }

  get dashboardRefreshFailed() {
    return this.dashboardRefreshOutcome === "failed";
  }

  get isComfortableDensity() {
    return this.density === "comfortable";
  }

  get isCompactDensity() {
    return this.density === "compact";
  }

  get currentUsername() {
    return this.currentUser?.username;
  }

  get profilePath() {
    return this.currentUsername
      ? `/u/${encodeURIComponent(this.currentUsername)}`
      : "/my/activity";
  }

  get bookmarksPath() {
    return this.currentUsername
      ? `/u/${encodeURIComponent(this.currentUsername)}/activity/bookmarks`
      : "/my/activity";
  }

  get notificationsPath() {
    return this.currentUsername
      ? `/u/${encodeURIComponent(this.currentUsername)}/notifications`
      : "/my/activity";
  }

  get draftsPath() {
    return this.currentUsername
      ? `/u/${encodeURIComponent(this.currentUsername)}/activity/drafts`
      : "/my/activity";
  }

  get unreadNotificationsCount() {
    return Math.max(
      Number(get(this.currentUser, "all_unread_notifications_count")) || 0,
      0,
    );
  }

  get newMessagesCount() {
    return Math.max(
      Number(
        get(this.currentUser, "new_personal_messages_notifications_count"),
      ) || 0,
      0,
    );
  }

  get draftsCount() {
    return Math.max(Number(get(this.currentUser, "draft_count")) || 0, 0);
  }

  get normalizedQuery() {
    return this.query.trim().toLowerCase();
  }

  get hasQuery() {
    return this.normalizedQuery.length > 0;
  }

  get filteredUsers() {
    const query = this.normalizedQuery;
    const filtered = query
      ? this.users.filter((user) => {
          const username = String(user?.username || "").toLowerCase();
          const name = String(user?.name || "").toLowerCase();

          return username.includes(query) || name.includes(query);
        })
      : [...this.users];

    if (this.sortMode === "recent") {
      return filtered;
    }

    return filtered.sort((left, right) => {
      if (this.sortMode === "username") {
        return String(left?.username || "").localeCompare(
          String(right?.username || ""),
          undefined,
          { sensitivity: "base" },
        );
      }

      const leftLabel = String(left?.name || left?.username || "");
      const rightLabel = String(right?.name || right?.username || "");
      return leftLabel.localeCompare(rightLabel, undefined, {
        sensitivity: "base",
      });
    });
  }

  @action
  updateQuery(event) {
    this.query = event.target.value;
  }

  @action
  updateSort(event) {
    this.sortMode = event.target.value;
  }

  @action
  clearQuery() {
    this.query = "";
  }

  @action
  useComfortableDensity() {
    this.density = "comfortable";
  }

  @action
  useCompactDensity() {
    this.density = "compact";
  }

  @action
  toggleVisitors() {
    this.showAllVisitors = !this.showAllVisitors;
  }

  async performSnapshotRefresh() {
    if (this.isRefreshing) {
      return !this.refreshFailed;
    }

    this.isRefreshing = true;
    this.refreshFailed = false;

    try {
      this.snapshot = await ajax("/crimson-community/online.json");
      return true;
    } catch {
      this.refreshFailed = true;
      return false;
    } finally {
      this.isRefreshing = false;
    }
  }

  async performVisitorRefresh() {
    if (this.isRefreshingVisitors) {
      return !this.visitorRefreshFailed;
    }

    this.isRefreshingVisitors = true;
    this.visitorRefreshFailed = false;

    try {
      this.visitors = await ajax("/crimson-community/profile-visits.json");
      this.showAllVisitors = false;
      return true;
    } catch {
      this.visitorRefreshFailed = true;
      return false;
    } finally {
      this.isRefreshingVisitors = false;
    }
  }

  @action
  async refreshSnapshot() {
    this.dashboardRefreshOutcome = null;
    await this.performSnapshotRefresh();
  }

  @action
  async refreshVisitors() {
    this.dashboardRefreshOutcome = null;
    await this.performVisitorRefresh();
  }

  @action
  async refreshDashboard() {
    if (this.isRefreshingDashboard) {
      return;
    }

    this.dashboardRefreshOutcome = null;

    const [presenceSucceeded, visitorsSucceeded] = await Promise.all([
      this.performSnapshotRefresh(),
      this.performVisitorRefresh(),
    ]);

    if (!presenceSucceeded && !visitorsSucceeded) {
      this.dashboardRefreshOutcome = "failed";
    } else if (!presenceSucceeded || !visitorsSucceeded) {
      this.dashboardRefreshOutcome = "partial";
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

        <div class="crimson-community-page__header-actions">
          <DButton
            @action={{this.refreshDashboard}}
            @icon="arrows-rotate"
            @label="crimson_community.page.refresh_dashboard"
            @isLoading={{this.isRefreshingDashboard}}
            class="btn-default"
            data-test-community-refresh-all
          />
          <a class="btn btn-default crimson-community-page__directory-link" href="/u">
            {{dIcon "users"}}
            <span>{{i18n "crimson_community.page.all_members"}}</span>
          </a>
        </div>
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

      <section
        class="crimson-community-actions"
        aria-labelledby="crimson-community-actions-title"
        data-test-community-actions
      >
        <header class="crimson-community-actions__header">
          <div class="crimson-community-actions__heading">
            <h2 id="crimson-community-actions-title">
              {{i18n "crimson_community.page.quick_actions_title"}}
            </h2>
            <p>{{i18n "crimson_community.page.quick_actions_description"}}</p>
          </div>
          <div class="crimson-community-actions__identity">
            <DUserInfo @user={{this.currentUser}} @headingLevel={{3}} @size="medium" />
          </div>
        </header>

        <nav
          class="crimson-community-actions__grid"
          aria-label={{i18n "crimson_community.page.quick_actions_label"}}
        >
          <a
            class="crimson-community-actions__link"
            href={{this.profilePath}}
            data-test-community-action-profile
          >
            <span class="crimson-community-actions__icon" aria-hidden="true">
              {{dIcon "user"}}
            </span>
            <span class="crimson-community-actions__copy">
              <strong>{{i18n "crimson_community.page.quick_action_profile"}}</strong>
              <span>{{i18n "crimson_community.page.quick_action_profile_description"}}</span>
            </span>
            <span class="crimson-community-actions__chevron" aria-hidden="true">
              {{dIcon "chevron-right"}}
            </span>
          </a>

          <a
            class="crimson-community-actions__link"
            href="/my/activity"
            data-test-community-action-posts
          >
            <span class="crimson-community-actions__icon" aria-hidden="true">
              {{dIcon "list"}}
            </span>
            <span class="crimson-community-actions__copy">
              <strong>{{i18n "crimson_community.page.quick_action_posts"}}</strong>
              <span>{{i18n "crimson_community.page.quick_action_posts_description"}}</span>
            </span>
            <span class="crimson-community-actions__chevron" aria-hidden="true">
              {{dIcon "chevron-right"}}
            </span>
          </a>

          <a
            class="crimson-community-actions__link"
            href="/my/messages"
            data-test-community-action-messages
          >
            <span class="crimson-community-actions__icon" aria-hidden="true">
              {{dIcon "inbox"}}
            </span>
            <span class="crimson-community-actions__copy">
              <strong class="crimson-community-actions__title">
                <span>{{i18n "crimson_community.page.quick_action_messages"}}</span>
                {{#if this.newMessagesCount}}
                  <span
                    class="badge-notification crimson-community-actions__badge"
                    aria-label={{i18n
                      "crimson_community.page.quick_action_messages_badge"
                      count=this.newMessagesCount
                    }}
                    data-test-community-action-messages-badge
                  >
                    {{this.newMessagesCount}}
                  </span>
                {{/if}}
              </strong>
              <span>{{i18n "crimson_community.page.quick_action_messages_description"}}</span>
            </span>
            <span class="crimson-community-actions__chevron" aria-hidden="true">
              {{dIcon "chevron-right"}}
            </span>
          </a>

          <a
            class="crimson-community-actions__link"
            href={{this.notificationsPath}}
            data-test-community-action-notifications
          >
            <span class="crimson-community-actions__icon" aria-hidden="true">
              {{dIcon "bell"}}
            </span>
            <span class="crimson-community-actions__copy">
              <strong class="crimson-community-actions__title">
                <span>{{i18n "crimson_community.page.quick_action_notifications"}}</span>
                {{#if this.unreadNotificationsCount}}
                  <span
                    class="badge-notification crimson-community-actions__badge"
                    aria-label={{i18n
                      "crimson_community.page.quick_action_notifications_badge"
                      count=this.unreadNotificationsCount
                    }}
                    data-test-community-action-notifications-badge
                  >
                    {{this.unreadNotificationsCount}}
                  </span>
                {{/if}}
              </strong>
              <span>{{i18n "crimson_community.page.quick_action_notifications_description"}}</span>
            </span>
            <span class="crimson-community-actions__chevron" aria-hidden="true">
              {{dIcon "chevron-right"}}
            </span>
          </a>

          <a
            class="crimson-community-actions__link"
            href={{this.bookmarksPath}}
            data-test-community-action-bookmarks
          >
            <span class="crimson-community-actions__icon" aria-hidden="true">
              {{dIcon "bookmark"}}
            </span>
            <span class="crimson-community-actions__copy">
              <strong>{{i18n "crimson_community.page.quick_action_bookmarks"}}</strong>
              <span>{{i18n "crimson_community.page.quick_action_bookmarks_description"}}</span>
            </span>
            <span class="crimson-community-actions__chevron" aria-hidden="true">
              {{dIcon "chevron-right"}}
            </span>
          </a>

          <a
            class="crimson-community-actions__link"
            href={{this.draftsPath}}
            data-test-community-action-drafts
          >
            <span class="crimson-community-actions__icon" aria-hidden="true">
              {{dIcon "pencil"}}
            </span>
            <span class="crimson-community-actions__copy">
              <strong class="crimson-community-actions__title">
                <span>{{i18n "crimson_community.page.quick_action_drafts"}}</span>
                {{#if this.draftsCount}}
                  <span
                    class="badge-notification crimson-community-actions__badge"
                    aria-label={{i18n
                      "crimson_community.page.quick_action_drafts_badge"
                      count=this.draftsCount
                    }}
                    data-test-community-action-drafts-badge
                  >
                    {{this.draftsCount}}
                  </span>
                {{/if}}
              </strong>
              <span>{{i18n "crimson_community.page.quick_action_drafts_description"}}</span>
            </span>
            <span class="crimson-community-actions__chevron" aria-hidden="true">
              {{dIcon "chevron-right"}}
            </span>
          </a>
        </nav>
      </section>

      {{#if this.dashboardRefreshPartial}}
        <div
          class="crimson-community-page__status crimson-community-page__status--warning"
          role="status"
          data-test-community-refresh-partial
        >
          {{dIcon "circle-exclamation"}}
          <span>{{i18n "crimson_community.page.dashboard_refresh_partial"}}</span>
        </div>
      {{else if this.dashboardRefreshFailed}}
        <div
          class="crimson-community-page__status crimson-community-page__status--error"
          role="alert"
          data-test-community-refresh-all-error
        >
          {{dIcon "circle-exclamation"}}
          <span>{{i18n "crimson_community.page.dashboard_refresh_failed"}}</span>
        </div>
      {{/if}}

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

      <div
        class="crimson-community-dashboard"
        data-density={{this.density}}
        data-test-community-dashboard
      >
        {{#if this.users.length}}
          <section
            class="crimson-community-members crimson-community-dashboard__primary"
            aria-labelledby="crimson-community-online-title"
          >
            <header class="crimson-community-members__header">
              <div>
                <h2 id="crimson-community-online-title">
                  {{i18n "crimson_community.page.online_members"}}
                </h2>
                <p>{{i18n "crimson_community.page.online_members_description"}}</p>
                {{#if this.snapshot.generated_at}}
                  <div
                    class="crimson-community-panel-meta"
                    data-test-community-online-updated
                  >
                    {{dIcon "clock"}}
                    <span>{{i18n "crimson_community.page.last_updated"}}</span>
                    <span>{{dFormatDate this.snapshot.generated_at format="tiny"}}</span>
                  </div>
                {{/if}}
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

              <div class="crimson-community-members__preferences">
                <div class="crimson-community-members__sort-field">
                  <label for="crimson-community-member-sort">
                    {{i18n "crimson_community.page.sort_label"}}
                  </label>
                  <select
                    id="crimson-community-member-sort"
                    class="crimson-community-members__sort-select"
                    value={{this.sortMode}}
                    data-test-community-sort
                    {{on "change" this.updateSort}}
                  >
                    <option value="recent">
                      {{i18n "crimson_community.page.sort_recent"}}
                    </option>
                    <option value="name">
                      {{i18n "crimson_community.page.sort_name"}}
                    </option>
                    <option value="username">
                      {{i18n "crimson_community.page.sort_username"}}
                    </option>
                  </select>
                </div>

                <div
                  class="crimson-community-density"
                  role="group"
                  aria-label={{i18n "crimson_community.page.density_label"}}
                >
                  <span class="crimson-community-density__label">
                    {{i18n "crimson_community.page.density_label"}}
                  </span>
                  <div class="crimson-community-density__buttons">
                    <button
                      type="button"
                      class={{if
                        this.isComfortableDensity
                        "btn btn-default is-active"
                        "btn btn-default"
                      }}
                      aria-pressed={{if this.isComfortableDensity "true" "false"}}
                      data-test-community-density-comfortable
                      {{on "click" this.useComfortableDensity}}
                    >
                      {{i18n "crimson_community.page.density_comfortable"}}
                    </button>
                    <button
                      type="button"
                      class={{if
                        this.isCompactDensity
                        "btn btn-default is-active"
                        "btn btn-default"
                      }}
                      aria-pressed={{if this.isCompactDensity "true" "false"}}
                      data-test-community-density-compact
                      {{on "click" this.useCompactDensity}}
                    >
                      {{i18n "crimson_community.page.density_compact"}}
                    </button>
                  </div>
                </div>
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
          <section class="crimson-community-empty crimson-community-dashboard__primary">
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

        <section
          class="crimson-community-visitors crimson-community-dashboard__secondary"
          aria-labelledby="crimson-community-visitors-title"
          data-test-community-visitors
        >
          <header class="crimson-community-visitors__header">
            <div>
              <h2 id="crimson-community-visitors-title">
                {{i18n "crimson_community.page.visitors_title"}}
              </h2>
              <p>{{i18n "crimson_community.page.visitors_description"}}</p>
              {{#if this.visitors.generated_at}}
                <div
                  class="crimson-community-panel-meta"
                  data-test-community-visitors-updated
                >
                  {{dIcon "clock"}}
                  <span>{{i18n "crimson_community.page.last_updated"}}</span>
                  <span>{{dFormatDate this.visitors.generated_at format="tiny"}}</span>
                </div>
              {{/if}}
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
              {{#each this.visibleVisitorUsers as |visitor|}}
                <article class="crimson-community-visitor-row">
                  <DUserInfo @user={{visitor}} @headingLevel={{3}} @size="large" />
                  <span class="crimson-community-visitor-row__time">
                    {{dIcon "clock"}}
                    {{dFormatDate visitor.last_visited_at format="tiny"}}
                  </span>
                </article>
              {{/each}}
            </div>

            {{#if this.hasMoreVisitorUsers}}
              <div class="crimson-community-visitors__list-toggle">
                {{#if this.showAllVisitors}}
                  <DButton
                    @action={{this.toggleVisitors}}
                    @icon="chevron-up"
                    @label="crimson_community.page.show_fewer_visitors"
                    class="btn-flat"
                    data-test-community-visitors-toggle
                  />
                {{else}}
                  <DButton
                    @action={{this.toggleVisitors}}
                    @icon="chevron-down"
                    @label="crimson_community.page.show_all_visitors"
                    class="btn-flat"
                    data-test-community-visitors-toggle
                  />
                {{/if}}
              </div>
            {{/if}}

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
      </div>
    </div>
  </template>
}

export default RouteTemplate(
  <template>
    <CrimsonCommunityPage @initialSnapshot={{@model}} />
  </template>,
);
