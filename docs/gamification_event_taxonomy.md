# Gamification Event Taxonomy (GAMI-101)

> **Version:** 1.1  
> **Owner:** Gamification squad  
> **Status:** Active  
> **Service:** `GamificationEventService` (`lib/features/gamification/data/gamification_event_service.dart`)

---

## 1. Schema

All gamification events are written to the `event_log` table with the following columns:

| Column        | Type          | Required | Description |
|---------------|---------------|----------|-------------|
| `id`          | `uuid`        | auto     | Primary key (server-generated) |
| `actor_id`    | `uuid`        | yes      | Authenticated user who triggered the event |
| `event_type`  | `text`        | yes      | Snake-case event identifier (see Section 2) |
| `entity_type` | `text`        | yes      | Domain category the event belongs to |
| `entity_id`   | `text`        | no       | ID of the specific entity involved (trip, mission, challenge, etc.) |
| `payload`     | `jsonb`       | no       | Structured event-specific metadata |
| `created_at`  | `timestamptz` | auto     | Server-side `now()` default |

### Entity Types

| entity_type      | Description |
|------------------|-------------|
| `trip`           | A ride/trip entity |
| `user`           | The acting user |
| `mission`        | A weekly mission instance |
| `wallet`         | The user's XP wallet/balance |
| `reward`         | A redeemable reward catalog item |
| `nba`            | A Next-Best-Action recommendation |
| `progress`       | A composite progress snapshot surface |
| `team_challenge` | Neighborhood/campus team challenge |
| `mastery_track`  | Trust or safety mastery progression |
| `bonus_window`   | Time/route-specific bonus opportunity |
| `experiment`     | A/B experiment cohort assignment/exposure |

---

## 2. Event Catalogue

### 2.1 Streak Events

| event_type         | entity_type | payload                     | Trigger |
|--------------------|-------------|-----------------------------|---------|
| `streak_continued` | `trip`      | `{ "new_count": int }`      | Trip completion extends active streak |
| `streak_broken`    | `user`      | `{ "final_count": int }`    | Day boundary passed without qualifying trip |
| `streak_recovered` | `trip`      | `{ "restored_count": int }` | Trip completed during grace period |

### 2.2 Mission Events

| event_type          | entity_type | payload                                          | Trigger |
|---------------------|-------------|--------------------------------------------------|---------|
| `mission_progress`  | `mission`   | `{ "current_count": int, "target_count": int }` | Qualifying action increments mission |
| `mission_completed` | `mission`   | `{ "reward_xp": int }`                            | Mission target met |

### 2.3 Wallet Events

| event_type        | entity_type | payload             | Trigger |
|-------------------|-------------|---------------------|---------|
| `wallet_viewed`   | `wallet`    | `{ "surface": string }` | User opens wallet screen |
| `reward_redeemed` | `reward`    | `{ "cost": int }`      | User redeems reward |

### 2.4 Next-Best-Action (NBA) Events

| event_type    | entity_type | payload                       | Trigger |
|---------------|-------------|-------------------------------|---------|
| `nba_shown`   | `nba`       | `{ "action_type": string }` | NBA card rendered |
| `nba_clicked` | `nba`       | `{ "action_type": string }` | User taps NBA CTA |

### 2.5 Progress Snapshot Events

| event_type        | entity_type | payload                 | Trigger |
|-------------------|-------------|-------------------------|---------|
| `progress_viewed` | `progress`  | `{ "surface": string }` | Progress snapshot loaded |

### 2.6 Team Challenge Events (GAMI-401)

| event_type                  | entity_type      | payload                                                     | Trigger |
|-----------------------------|------------------|-------------------------------------------------------------|---------|
| `team_challenge_joined`     | `team_challenge` | `{ "challenge_id": string, "team_id": string }`            | User joins challenge team |
| `team_challenge_progress`   | `team_challenge` | `{ "challenge_id": string, "team_id": string, "progress": int }` | Team progress updated |
| `team_challenge_completed`  | `team_challenge` | `{ "challenge_id": string, "team_id": string, "reward_xp": int }` | Challenge target reached |

### 2.7 Trust/Safety Mastery Events (GAMI-402)

| event_type                 | entity_type     | payload                                                        | Trigger |
|----------------------------|-----------------|----------------------------------------------------------------|---------|
| `mastery_progressed`       | `mastery_track` | `{ "track": string, "level": int, "progress_pct": number }` | Progress change in mastery track |
| `mastery_level_unlocked`   | `mastery_track` | `{ "track": string, "level": int }`                           | User unlocks mastery level |
| `mastery_track_completed`  | `mastery_track` | `{ "track": string, "final_level": int }`                     | User completes mastery track |

### 2.8 Smart Bonus Window Events (GAMI-403)

| event_type              | entity_type    | payload                                                                    | Trigger |
|-------------------------|----------------|----------------------------------------------------------------------------|---------|
| `bonus_window_exposed`  | `bonus_window` | `{ "window_id": string, "route_key": string, "multiplier": number }`   | Eligible bonus shown |
| `bonus_window_claimed`  | `bonus_window` | `{ "window_id": string, "route_key": string, "reward_xp": int }`        | Bonus earned/claimed |
| `bonus_window_expired`  | `bonus_window` | `{ "window_id": string, "reason": string }`                              | Window closes without claim |

### 2.9 Experiment/Cohort Events (GAMI-404)

| event_type             | entity_type   | payload                                                                         | Trigger |
|------------------------|---------------|---------------------------------------------------------------------------------|---------|
| `cohort_assigned`      | `experiment`  | `{ "cohort": string, "variant": string }`                                      | User assigned to experiment |
| `feature_exposed`      | `experiment`  | `{ "cohort": string, "variant": string, "feature_flag": string }`            | Experimented surface rendered |
| `experiment_converted` | `experiment`  | `{ "cohort": string, "variant": string, "goal": string, "value": number }` | Tracked conversion outcome |

---

## 3. Naming Conventions

1. `event_type`: `<noun>_<past_tense_verb>` (example: `streak_continued`).
2. `entity_type`: singular lowercase noun matching domain concept.
3. `payload` keys: `snake_case`, flat or one-level nested only.
4. XP amounts are integers; percentages are numeric (`0..100`); timestamps use ISO-8601 UTC.

---

## 4. Service Method Mapping

| Dart Method | event_type |
|-------------|------------|
| `logStreakContinued()` | `streak_continued` |
| `logStreakBroken()` | `streak_broken` |
| `logStreakRecovered()` | `streak_recovered` |
| `logMissionProgress()` | `mission_progress` |
| `logMissionCompleted()` | `mission_completed` |
| `logWalletViewed()` | `wallet_viewed` |
| `logRewardRedeemed()` | `reward_redeemed` |
| `logNbaShown()` | `nba_shown` |
| `logNbaClicked()` | `nba_clicked` |
| `logProgressViewed()` | `progress_viewed` |
| `logCohortAssigned()` | `cohort_assigned` |
| `logFeatureExposed()` | `feature_exposed` |
| `logTeamChallengeJoined()` *(GAMI-401)* | `team_challenge_joined` |
| `logTeamChallengeProgress()` *(GAMI-401)* | `team_challenge_progress` |
| `logTeamChallengeCompleted()` *(GAMI-401)* | `team_challenge_completed` |
| `logMasteryProgressed()` *(GAMI-402)* | `mastery_progressed` |
| `logMasteryLevelUnlocked()` *(GAMI-402)* | `mastery_level_unlocked` |
| `logBonusWindowExposed()` *(GAMI-403)* | `bonus_window_exposed` |
| `logBonusWindowClaimed()` *(GAMI-403)* | `bonus_window_claimed` |
| `logExperimentConverted()` *(GAMI-404)* | `experiment_converted` |

---

## 5. Integration Rules

| Rule | Description |
|------|-------------|
| Fire-and-forget | Callers do not `await` logging on critical ride paths. |
| Auth guard | Drop event if `auth.currentUser` is null. |
| No PII in payload | Do not log names, email, phone, exact coordinates. |
| Idempotency | Event log is append-only; dedupe in analytics layer. |
| Required experiment context | Tier-2 events must include `cohort_id` and `experiment_id` when available. |

---

## 6. Analytics Queries (examples)

```sql
-- Team challenge completion by cohort
SELECT
  payload->>'team_id' AS team_id,
  payload->>'cohort' AS cohort,
  COUNT(*) FILTER (WHERE event_type = 'team_challenge_joined') AS joined,
  COUNT(*) FILTER (WHERE event_type = 'team_challenge_completed') AS completed
FROM event_log
WHERE event_type IN ('team_challenge_joined', 'team_challenge_completed')
GROUP BY 1,2;

-- Bonus window conversion rate by variant
SELECT
  payload->>'variant' AS variant,
  COUNT(*) FILTER (WHERE event_type = 'bonus_window_exposed') AS exposed,
  COUNT(*) FILTER (WHERE event_type = 'bonus_window_claimed') AS claimed,
  ROUND(
    COUNT(*) FILTER (WHERE event_type = 'bonus_window_claimed')::numeric /
    NULLIF(COUNT(*) FILTER (WHERE event_type = 'bonus_window_exposed'), 0),
    4
  ) AS claim_rate
FROM event_log
WHERE event_type IN ('bonus_window_exposed', 'bonus_window_claimed')
GROUP BY 1;
```

---

## 7. Future Extensions (Tier-3)

| event_type            | entity_type  | Notes |
|-----------------------|--------------|-------|
| `city_impact_milestone` | `impact`   | Narrative city-impact progression |
| `premium_multiplier_applied` | `premium` | Khawi+ multiplier application |
| `season_reset`        | `season`     | Seasonal ladder reset event |
