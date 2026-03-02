export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      area_incentives: {
        Row: {
          area_id: string
          computed_at: string
          dynamic_xp_multiplier: number
          id: string
          reason_tag: string | null
          time_bucket: string
        }
        Insert: {
          area_id: string
          computed_at?: string
          dynamic_xp_multiplier?: number
          id?: string
          reason_tag?: string | null
          time_bucket: string
        }
        Update: {
          area_id?: string
          computed_at?: string
          dynamic_xp_multiplier?: number
          id?: string
          reason_tag?: string | null
          time_bucket?: string
        }
        Relationships: []
      }
      bundle_suggestions: {
        Row: {
          acceptability_score: number
          computed_at: string
          detour_by_passenger: Json
          driver_id: string
          id: string
          model_version: string
          passenger_ids: string[]
          suggested_order: Json
          trip_id: string
        }
        Insert: {
          acceptability_score?: number
          computed_at?: string
          detour_by_passenger?: Json
          driver_id: string
          id?: string
          model_version?: string
          passenger_ids?: string[]
          suggested_order: Json
          trip_id: string
        }
        Update: {
          acceptability_score?: number
          computed_at?: string
          detour_by_passenger?: Json
          driver_id?: string
          id?: string
          model_version?: string
          passenger_ids?: string[]
          suggested_order?: Json
          trip_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "bundle_suggestions_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bundle_suggestions_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bundle_suggestions_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
        ]
      }
      commute_templates: {
        Row: {
          active: boolean
          created_at: string
          depart_time_local: string
          destination: Json
          id: string
          name: string | null
          origin: Json
          prefs: Json
          return_time_local: string | null
          updated_at: string
          user_id: string
          weekday_mask: number
        }
        Insert: {
          active?: boolean
          created_at?: string
          depart_time_local: string
          destination: Json
          id?: string
          name?: string | null
          origin: Json
          prefs?: Json
          return_time_local?: string | null
          updated_at?: string
          user_id: string
          weekday_mask?: number
        }
        Update: {
          active?: boolean
          created_at?: string
          depart_time_local?: string
          destination?: Json
          id?: string
          name?: string | null
          origin?: Json
          prefs?: Json
          return_time_local?: string | null
          updated_at?: string
          user_id?: string
          weekday_mask?: number
        }
        Relationships: [
          {
            foreignKeyName: "commute_templates_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commute_templates_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      daily_suggestions: {
        Row: {
          computed_at: string
          expires_at: string | null
          id: string
          model_version: string
          payload: Json
          reason_tags: string[]
          score: number
          suggestion_type: string
          user_id: string
        }
        Insert: {
          computed_at?: string
          expires_at?: string | null
          id?: string
          model_version?: string
          payload: Json
          reason_tags?: string[]
          score?: number
          suggestion_type: string
          user_id: string
        }
        Update: {
          computed_at?: string
          expires_at?: string | null
          id?: string
          model_version?: string
          payload?: Json
          reason_tags?: string[]
          score?: number
          suggestion_type?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "daily_suggestions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "daily_suggestions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      edge_rate_limits: {
        Row: {
          count: number
          key: string
          updated_at: string
          window_start: string
        }
        Insert: {
          count?: number
          key: string
          updated_at?: string
          window_start: string
        }
        Update: {
          count?: number
          key?: string
          updated_at?: string
          window_start?: string
        }
        Relationships: []
      }
      event_log: {
        Row: {
          actor_id: string | null
          created_at: string
          entity_id: string | null
          entity_type: string | null
          event_type: string
          id: number
          payload: Json
        }
        Insert: {
          actor_id?: string | null
          created_at?: string
          entity_id?: string | null
          entity_type?: string | null
          event_type: string
          id?: number
          payload?: Json
        }
        Update: {
          actor_id?: string | null
          created_at?: string
          entity_id?: string | null
          entity_type?: string | null
          event_type?: string
          id?: number
          payload?: Json
        }
        Relationships: [
          {
            foreignKeyName: "event_log_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "event_log_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      feature_flags: {
        Row: {
          enabled: boolean
          name: string
          rollout_percentage: number
          segment_filter: Json
          updated_at: string
        }
        Insert: {
          enabled?: boolean
          name: string
          rollout_percentage?: number
          segment_filter?: Json
          updated_at?: string
        }
        Update: {
          enabled?: boolean
          name?: string
          rollout_percentage?: number
          segment_filter?: Json
          updated_at?: string
        }
        Relationships: []
      }
      fraud_flags: {
        Row: {
          created_at: string
          entity_id: string
          entity_type: string
          evidence_json: Json | null
          flag_type: string
          id: string
          resolved_at: string | null
          severity: string | null
        }
        Insert: {
          created_at?: string
          entity_id: string
          entity_type: string
          evidence_json?: Json | null
          flag_type: string
          id?: string
          resolved_at?: string | null
          severity?: string | null
        }
        Update: {
          created_at?: string
          entity_id?: string
          entity_type?: string
          evidence_json?: Json | null
          flag_type?: string
          id?: string
          resolved_at?: string | null
          severity?: string | null
        }
        Relationships: []
      }
      junior_driver_grants: {
        Row: {
          created_at: string
          driver_id: string
          ends_at: string
          id: string
          is_active: boolean
          kid_id: string | null
          parent_id: string
          run_id: string | null
          starts_at: string
        }
        Insert: {
          created_at?: string
          driver_id: string
          ends_at: string
          id?: string
          is_active?: boolean
          kid_id?: string | null
          parent_id: string
          run_id?: string | null
          starts_at: string
        }
        Update: {
          created_at?: string
          driver_id?: string
          ends_at?: string
          id?: string
          is_active?: boolean
          kid_id?: string | null
          parent_id?: string
          run_id?: string | null
          starts_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "junior_driver_grants_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_driver_grants_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_driver_grants_kid_id_fkey"
            columns: ["kid_id"]
            isOneToOne: false
            referencedRelation: "kids"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_driver_grants_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_driver_grants_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_driver_grants_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "junior_runs"
            referencedColumns: ["id"]
          },
        ]
      }
      junior_invite_codes: {
        Row: {
          code: string
          created_at: string
          expires_at: string
          id: string
          is_used: boolean
          parent_id: string
          run_id: string
        }
        Insert: {
          code: string
          created_at?: string
          expires_at: string
          id?: string
          is_used?: boolean
          parent_id: string
          run_id: string
        }
        Update: {
          code?: string
          created_at?: string
          expires_at?: string
          id?: string
          is_used?: boolean
          parent_id?: string
          run_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "junior_invite_codes_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_invite_codes_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_invite_codes_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: true
            referencedRelation: "junior_runs"
            referencedColumns: ["id"]
          },
        ]
      }
      junior_run_events: {
        Row: {
          actor_id: string
          actor_role: string
          created_at: string
          event_type: string
          id: string
          lat: number | null
          lng: number | null
          meta: Json | null
          new_status: string | null
          prev_status: string | null
          run_id: string
        }
        Insert: {
          actor_id: string
          actor_role: string
          created_at?: string
          event_type: string
          id?: string
          lat?: number | null
          lng?: number | null
          meta?: Json | null
          new_status?: string | null
          prev_status?: string | null
          run_id: string
        }
        Update: {
          actor_id?: string
          actor_role?: string
          created_at?: string
          event_type?: string
          id?: string
          lat?: number | null
          lng?: number | null
          meta?: Json | null
          new_status?: string | null
          prev_status?: string | null
          run_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "junior_run_events_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_run_events_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_run_events_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "junior_runs"
            referencedColumns: ["id"]
          },
        ]
      }
      junior_run_locations: {
        Row: {
          accuracy: number | null
          created_at: string
          heading: number | null
          id: string
          lat: number
          lng: number
          run_id: string
          speed: number | null
          user_id: string
        }
        Insert: {
          accuracy?: number | null
          created_at?: string
          heading?: number | null
          id?: string
          lat: number
          lng: number
          run_id: string
          speed?: number | null
          user_id: string
        }
        Update: {
          accuracy?: number | null
          created_at?: string
          heading?: number | null
          id?: string
          lat?: number
          lng?: number
          run_id?: string
          speed?: number | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "junior_run_locations_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "junior_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_run_locations_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_run_locations_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      junior_runs: {
        Row: {
          assigned_driver_id: string | null
          created_at: string
          dropoff_lat: number
          dropoff_lng: number
          id: string
          kid_id: string
          parent_id: string
          pickup_lat: number
          pickup_lng: number
          pickup_time: string
          status: string
          trip_id: string | null
          updated_at: string
        }
        Insert: {
          assigned_driver_id?: string | null
          created_at?: string
          dropoff_lat: number
          dropoff_lng: number
          id?: string
          kid_id: string
          parent_id: string
          pickup_lat: number
          pickup_lng: number
          pickup_time: string
          status?: string
          trip_id?: string | null
          updated_at?: string
        }
        Update: {
          assigned_driver_id?: string | null
          created_at?: string
          dropoff_lat?: number
          dropoff_lng?: number
          id?: string
          kid_id?: string
          parent_id?: string
          pickup_lat?: number
          pickup_lng?: number
          pickup_time?: string
          status?: string
          trip_id?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "junior_runs_assigned_driver_id_fkey"
            columns: ["assigned_driver_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_runs_assigned_driver_id_fkey"
            columns: ["assigned_driver_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_runs_kid_id_fkey"
            columns: ["kid_id"]
            isOneToOne: false
            referencedRelation: "kids"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_runs_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_runs_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_runs_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
        ]
      }
      kids: {
        Row: {
          avatar_url: string | null
          created_at: string
          id: string
          name: string
          notes: string | null
          parent_id: string
          school_name: string | null
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          id?: string
          name: string
          notes?: string | null
          parent_id: string
          school_name?: string | null
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          id?: string
          name?: string
          notes?: string | null
          parent_id?: string
          school_name?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "kids_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "kids_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      match_scores: {
        Row: {
          accept_prob: number
          computed_at: string
          detour_minutes: number
          explanation_tags: string[]
          match_score: number
          model_version: string
          overlap_ratio: number
          trip_id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          accept_prob: number
          computed_at?: string
          detour_minutes?: number
          explanation_tags?: string[]
          match_score: number
          model_version?: string
          overlap_ratio?: number
          trip_id: string
          updated_at?: string
          user_id: string
        }
        Update: {
          accept_prob?: number
          computed_at?: string
          detour_minutes?: number
          explanation_tags?: string[]
          match_score?: number
          model_version?: string
          overlap_ratio?: number
          trip_id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "match_scores_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "match_scores_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "match_scores_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      moderation_events: {
        Row: {
          actor_id: string | null
          created_at: string
          id: string
          message_id: string
          meta: Json
          model_version: string
          reason_code: string
          severity: number
          status: string
          trip_id: string
        }
        Insert: {
          actor_id?: string | null
          created_at?: string
          id?: string
          message_id: string
          meta?: Json
          model_version: string
          reason_code: string
          severity: number
          status: string
          trip_id: string
        }
        Update: {
          actor_id?: string | null
          created_at?: string
          id?: string
          message_id?: string
          meta?: Json
          model_version?: string
          reason_code?: string
          severity?: number
          status?: string
          trip_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "moderation_events_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "moderation_events_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "moderation_events_message_id_fkey"
            columns: ["message_id"]
            isOneToOne: false
            referencedRelation: "trip_messages"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "moderation_events_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          body: string
          created_at: string | null
          id: string
          is_read: boolean | null
          metadata: Json | null
          title: string
          type: string | null
          user_id: string | null
        }
        Insert: {
          body: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          metadata?: Json | null
          title: string
          type?: string | null
          user_id?: string | null
        }
        Update: {
          body?: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          metadata?: Json | null
          title?: string
          type?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "notifications_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_extensions: {
        Row: {
          activity_windows: Json
          city: string | null
          family_context: Json | null
          neighborhood: string | null
          purposes: string[]
          roles: string[]
          updated_at: string
          user_id: string
          vehicle_info: Json | null
        }
        Insert: {
          activity_windows?: Json
          city?: string | null
          family_context?: Json | null
          neighborhood?: string | null
          purposes?: string[]
          roles?: string[]
          updated_at?: string
          user_id: string
          vehicle_info?: Json | null
        }
        Update: {
          activity_windows?: Json
          city?: string | null
          family_context?: Json | null
          neighborhood?: string | null
          purposes?: string[]
          roles?: string[]
          updated_at?: string
          user_id?: string
          vehicle_info?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "profile_extensions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profile_extensions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          behavior_score: number | null
          created_at: string
          full_name: string
          gender: string | null
          id: string
          is_premium: boolean
          is_verified: boolean
          neighborhood_id: string | null
          redeemable_xp: number
          role: string
          stripe_customer_id: string | null
          subscription_status: string | null
          total_xp: number
          updated_at: string
          xp_throttle: boolean
          xp_throttle_until: string | null
        }
        Insert: {
          avatar_url?: string | null
          behavior_score?: number | null
          created_at?: string
          full_name?: string
          gender?: string | null
          id: string
          is_premium?: boolean
          is_verified?: boolean
          neighborhood_id?: string | null
          redeemable_xp?: number
          role?: string
          stripe_customer_id?: string | null
          subscription_status?: string | null
          total_xp?: number
          updated_at?: string
          xp_throttle?: boolean
          xp_throttle_until?: string | null
        }
        Update: {
          avatar_url?: string | null
          behavior_score?: number | null
          created_at?: string
          full_name?: string
          gender?: string | null
          id?: string
          is_premium?: boolean
          is_verified?: boolean
          neighborhood_id?: string | null
          redeemable_xp?: number
          role?: string
          stripe_customer_id?: string | null
          subscription_status?: string | null
          total_xp?: number
          updated_at?: string
          xp_throttle?: boolean
          xp_throttle_until?: string | null
        }
        Relationships: []
      }
      ratings: {
        Row: {
          comment: string | null
          created_at: string | null
          id: string
          ratee_id: string | null
          rater_id: string | null
          stars: number | null
          tags: string[] | null
          trip_id: string | null
        }
        Insert: {
          comment?: string | null
          created_at?: string | null
          id?: string
          ratee_id?: string | null
          rater_id?: string | null
          stars?: number | null
          tags?: string[] | null
          trip_id?: string | null
        }
        Update: {
          comment?: string | null
          created_at?: string | null
          id?: string
          ratee_id?: string | null
          rater_id?: string | null
          stars?: number | null
          tags?: string[] | null
          trip_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "ratings_ratee_id_fkey"
            columns: ["ratee_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ratings_ratee_id_fkey"
            columns: ["ratee_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ratings_rater_id_fkey"
            columns: ["rater_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ratings_rater_id_fkey"
            columns: ["rater_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ratings_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
        ]
      }
      reports: {
        Row: {
          category: string
          created_at: string
          details: string | null
          id: string
          message_id: string | null
          reported_user_id: string | null
          reporter_id: string
          severity: number
          status: string
          trip_id: string | null
          updated_at: string
        }
        Insert: {
          category: string
          created_at?: string
          details?: string | null
          id?: string
          message_id?: string | null
          reported_user_id?: string | null
          reporter_id: string
          severity?: number
          status?: string
          trip_id?: string | null
          updated_at?: string
        }
        Update: {
          category?: string
          created_at?: string
          details?: string | null
          id?: string
          message_id?: string | null
          reported_user_id?: string | null
          reporter_id?: string
          severity?: number
          status?: string
          trip_id?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "reports_message_id_fkey"
            columns: ["message_id"]
            isOneToOne: false
            referencedRelation: "trip_messages"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reports_reported_user_id_fkey"
            columns: ["reported_user_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reports_reported_user_id_fkey"
            columns: ["reported_user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reports_reporter_id_fkey"
            columns: ["reporter_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reports_reporter_id_fkey"
            columns: ["reporter_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reports_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
        ]
      }
      sos_events: {
        Row: {
          created_at: string
          driver_id: string | null
          id: string
          kind: string
          lat: number
          lng: number
          message: string | null
          meta: Json | null
          parent_id: string | null
          run_id: string | null
          severity: number
          status: string
          triggered_by: string
          trip_id: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          driver_id?: string | null
          id?: string
          kind?: string
          lat: number
          lng: number
          message?: string | null
          meta?: Json | null
          parent_id?: string | null
          run_id?: string | null
          severity?: number
          status?: string
          triggered_by: string
          trip_id?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          driver_id?: string | null
          id?: string
          kind?: string
          lat?: number
          lng?: number
          message?: string | null
          meta?: Json | null
          parent_id?: string | null
          run_id?: string | null
          severity?: number
          status?: string
          triggered_by?: string
          trip_id?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "sos_events_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sos_events_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sos_events_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sos_events_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sos_events_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "junior_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sos_events_triggered_by_fkey"
            columns: ["triggered_by"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sos_events_triggered_by_fkey"
            columns: ["triggered_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sos_events_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
        ]
      }
      spatial_ref_sys: {
        Row: {
          auth_name: string | null
          auth_srid: number | null
          proj4text: string | null
          srid: number
          srtext: string | null
        }
        Insert: {
          auth_name?: string | null
          auth_srid?: number | null
          proj4text?: string | null
          srid: number
          srtext?: string | null
        }
        Update: {
          auth_name?: string | null
          auth_srid?: number | null
          proj4text?: string | null
          srid?: number
          srtext?: string | null
        }
        Relationships: []
      }
      streak_stats: {
        Row: {
          driver_streak: number
          last_driver_trip_at: string | null
          last_passenger_trip_at: string | null
          passenger_streak: number
          updated_at: string
          user_id: string
        }
        Insert: {
          driver_streak?: number
          last_driver_trip_at?: string | null
          last_passenger_trip_at?: string | null
          passenger_streak?: number
          updated_at?: string
          user_id: string
        }
        Update: {
          driver_streak?: number
          last_driver_trip_at?: string | null
          last_passenger_trip_at?: string | null
          passenger_streak?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "streak_stats_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "streak_stats_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      support_ai_outputs: {
        Row: {
          action_tags: string[]
          classification: string
          created_at: string
          id: string
          meta: Json
          model_version: string
          sentiment: string
          suggested_reply: string | null
          summary: string
          ticket_id: string
        }
        Insert: {
          action_tags?: string[]
          classification: string
          created_at?: string
          id?: string
          meta?: Json
          model_version?: string
          sentiment: string
          suggested_reply?: string | null
          summary: string
          ticket_id: string
        }
        Update: {
          action_tags?: string[]
          classification?: string
          created_at?: string
          id?: string
          meta?: Json
          model_version?: string
          sentiment?: string
          suggested_reply?: string | null
          summary?: string
          ticket_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "support_ai_outputs_ticket_id_fkey"
            columns: ["ticket_id"]
            isOneToOne: false
            referencedRelation: "support_tickets"
            referencedColumns: ["id"]
          },
        ]
      }
      support_tickets: {
        Row: {
          attachments: Json
          body: string
          booking_id: string | null
          channel: string
          created_at: string
          created_by: string | null
          id: string
          priority: number
          status: string
          subject: string | null
          trip_id: string | null
          updated_at: string
        }
        Insert: {
          attachments?: Json
          body: string
          booking_id?: string | null
          channel?: string
          created_at?: string
          created_by?: string | null
          id?: string
          priority?: number
          status?: string
          subject?: string | null
          trip_id?: string | null
          updated_at?: string
        }
        Update: {
          attachments?: Json
          body?: string
          booking_id?: string | null
          channel?: string
          created_at?: string
          created_by?: string | null
          id?: string
          priority?: number
          status?: string
          subject?: string | null
          trip_id?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "support_tickets_booking_id_fkey"
            columns: ["booking_id"]
            isOneToOne: false
            referencedRelation: "trip_requests"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_tickets_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_tickets_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_tickets_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
        ]
      }
      trip_locations: {
        Row: {
          created_at: string
          heading: number | null
          id: string
          lat: number
          lng: number
          speed: number | null
          trip_id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          heading?: number | null
          id?: string
          lat: number
          lng: number
          speed?: number | null
          trip_id: string
          user_id: string
        }
        Update: {
          created_at?: string
          heading?: number | null
          id?: string
          lat?: number
          lng?: number
          speed?: number | null
          trip_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "trip_locations_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trip_locations_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trip_locations_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      trip_messages: {
        Row: {
          body: string
          created_at: string
          id: string
          moderation_model_version: string | null
          moderation_reason_code: string | null
          moderation_status: string
          sender_id: string
          trip_id: string
        }
        Insert: {
          body: string
          created_at?: string
          id?: string
          moderation_model_version?: string | null
          moderation_reason_code?: string | null
          moderation_status?: string
          sender_id: string
          trip_id: string
        }
        Update: {
          body?: string
          created_at?: string
          id?: string
          moderation_model_version?: string | null
          moderation_reason_code?: string | null
          moderation_status?: string
          sender_id?: string
          trip_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "trip_messages_sender_id_fkey"
            columns: ["sender_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trip_messages_sender_id_fkey"
            columns: ["sender_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trip_messages_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
        ]
      }
      trip_requests: {
        Row: {
          created_at: string
          driver_id: string | null
          id: string
          passenger_id: string
          pickup_label: string | null
          pickup_lat: number | null
          pickup_lng: number | null
          status: string
          trip_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          driver_id?: string | null
          id?: string
          passenger_id: string
          pickup_label?: string | null
          pickup_lat?: number | null
          pickup_lng?: number | null
          status?: string
          trip_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          driver_id?: string | null
          id?: string
          passenger_id?: string
          pickup_label?: string | null
          pickup_lat?: number | null
          pickup_lng?: number | null
          status?: string
          trip_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "trip_requests_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trip_requests_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trip_requests_passenger_id_fkey"
            columns: ["passenger_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trip_requests_passenger_id_fkey"
            columns: ["passenger_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trip_requests_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
        ]
      }
      trips: {
        Row: {
          created_at: string
          departure_time: string
          dest_label: string | null
          dest_lat: number
          dest_lng: number
          driver_id: string
          eta_minutes: number | null
          id: string
          is_kids_ride: boolean
          is_recurring: boolean
          neighborhood_id: string | null
          origin_label: string | null
          origin_lat: number
          origin_lng: number
          polyline: string | null
          route_bbox: Json | null
          route_km: number | null
          route_minutes: number | null
          schedule_json: Json | null
          seats_available: number
          seats_total: number
          status: string
          tags: string[]
          updated_at: string
          women_only: boolean
        }
        Insert: {
          created_at?: string
          departure_time: string
          dest_label?: string | null
          dest_lat: number
          dest_lng: number
          driver_id: string
          eta_minutes?: number | null
          id?: string
          is_kids_ride?: boolean
          is_recurring?: boolean
          neighborhood_id?: string | null
          origin_label?: string | null
          origin_lat: number
          origin_lng: number
          polyline?: string | null
          route_bbox?: Json | null
          route_km?: number | null
          route_minutes?: number | null
          schedule_json?: Json | null
          seats_available?: number
          seats_total?: number
          status?: string
          tags?: string[]
          updated_at?: string
          women_only?: boolean
        }
        Update: {
          created_at?: string
          departure_time?: string
          dest_label?: string | null
          dest_lat?: number
          dest_lng?: number
          driver_id?: string
          eta_minutes?: number | null
          id?: string
          is_kids_ride?: boolean
          is_recurring?: boolean
          neighborhood_id?: string | null
          origin_label?: string | null
          origin_lat?: number
          origin_lng?: number
          polyline?: string | null
          route_bbox?: Json | null
          route_km?: number | null
          route_minutes?: number | null
          schedule_json?: Json | null
          seats_available?: number
          seats_total?: number
          status?: string
          tags?: string[]
          updated_at?: string
          women_only?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "trips_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trips_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      trust_profiles: {
        Row: {
          computed_at: string
          junior_trusted: boolean
          trust_badge: string | null
          trust_score: number
          user_id: string
        }
        Insert: {
          computed_at?: string
          junior_trusted?: boolean
          trust_badge?: string | null
          trust_score?: number
          user_id: string
        }
        Update: {
          computed_at?: string
          junior_trusted?: boolean
          trust_badge?: string | null
          trust_score?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "trust_profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trust_profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      trusted_drivers: {
        Row: {
          created_at: string
          driver_id: string
          id: string
          is_active: boolean
          label: string | null
          parent_id: string
        }
        Insert: {
          created_at?: string
          driver_id: string
          id?: string
          is_active?: boolean
          label?: string | null
          parent_id: string
        }
        Update: {
          created_at?: string
          driver_id?: string
          id?: string
          is_active?: boolean
          label?: string | null
          parent_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "trusted_drivers_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trusted_drivers_driver_id_fkey"
            columns: ["driver_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trusted_drivers_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "trusted_drivers_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_gamification: {
        Row: {
          last_active_date: string | null
          streak_days: number
          trips_completed_today: number
          trips_completed_today_date: string | null
          trips_completed_total: number
          updated_at: string
          user_id: string
        }
        Insert: {
          last_active_date?: string | null
          streak_days?: number
          trips_completed_today?: number
          trips_completed_today_date?: string | null
          trips_completed_total?: number
          updated_at?: string
          user_id: string
        }
        Update: {
          last_active_date?: string | null
          streak_days?: number
          trips_completed_today?: number
          trips_completed_today_date?: string | null
          trips_completed_total?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_gamification_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_gamification_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      xp_events: {
        Row: {
          base_xp: number
          bonus_xp: number
          created_at: string
          id: string
          meta: Json | null
          multiplier: number
          source: string
          total_xp: number
          trip_id: string | null
          user_id: string
        }
        Insert: {
          base_xp: number
          bonus_xp?: number
          created_at?: string
          id?: string
          meta?: Json | null
          multiplier?: number
          source: string
          total_xp: number
          trip_id?: string | null
          user_id: string
        }
        Update: {
          base_xp?: number
          bonus_xp?: number
          created_at?: string
          id?: string
          meta?: Json | null
          multiplier?: number
          source?: string
          total_xp?: number
          trip_id?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "xp_events_trip_id_fkey"
            columns: ["trip_id"]
            isOneToOne: false
            referencedRelation: "trips"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "xp_events_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "xp_events_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      xp_rules: {
        Row: {
          config: Json
          id: string
          is_active: boolean
          rule_key: string
          updated_at: string
        }
        Insert: {
          config: Json
          id?: string
          is_active?: boolean
          rule_key: string
          updated_at?: string
        }
        Update: {
          config?: Json
          id?: string
          is_active?: boolean
          rule_key?: string
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      geography_columns: {
        Row: {
          coord_dimension: number | null
          f_geography_column: unknown
          f_table_catalog: unknown
          f_table_name: unknown
          f_table_schema: unknown
          srid: number | null
          type: string | null
        }
        Relationships: []
      }
      geometry_columns: {
        Row: {
          coord_dimension: number | null
          f_geometry_column: unknown
          f_table_catalog: string | null
          f_table_name: unknown
          f_table_schema: unknown
          srid: number | null
          type: string | null
        }
        Insert: {
          coord_dimension?: number | null
          f_geometry_column?: unknown
          f_table_catalog?: string | null
          f_table_name?: unknown
          f_table_schema?: unknown
          srid?: number | null
          type?: string | null
        }
        Update: {
          coord_dimension?: number | null
          f_geometry_column?: unknown
          f_table_catalog?: string | null
          f_table_name?: unknown
          f_table_schema?: unknown
          srid?: number | null
          type?: string | null
        }
        Relationships: []
      }
      junior_run_latest_location: {
        Row: {
          accuracy: number | null
          created_at: string | null
          heading: number | null
          lat: number | null
          lng: number | null
          run_id: string | null
          speed: number | null
          user_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "junior_run_locations_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "junior_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_run_locations_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile_with_trust"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "junior_run_locations_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_with_trust: {
        Row: {
          avatar_url: string | null
          created_at: string | null
          full_name: string | null
          gender: string | null
          id: string | null
          is_premium: boolean | null
          is_verified: boolean | null
          junior_trusted: boolean | null
          neighborhood_id: string | null
          redeemable_xp: number | null
          role: string | null
          total_xp: number | null
          trust_badge: string | null
          trust_score: number | null
          updated_at: string | null
          xp_throttle: boolean | null
          xp_throttle_until: string | null
        }
        Relationships: []
      }
      rating_funnel_by_role_daily: {
        Row: {
          day: string | null
          role: string | null
          submit_failed: number | null
          submit_rate_pct: number | null
          submitted: number | null
          targets_missing: number | null
          targets_resolved: number | null
        }
        Relationships: []
      }
      rating_funnel_daily: {
        Row: {
          day: string | null
          resolved_fallback: number | null
          resolved_passenger_direct: number | null
          resolved_selected: number | null
          submission_fail_rate_pct: number | null
          submission_failed: number | null
          submit_rate_pct: number | null
          submitted: number | null
          target_missing: number | null
        }
        Relationships: []
      }
    }
    Functions: {
      _postgis_deprecate: {
        Args: { newname: string; oldname: string; version: string }
        Returns: undefined
      }
      _postgis_index_extent: {
        Args: { col: string; tbl: unknown }
        Returns: unknown
      }
      _postgis_pgsql_version: { Args: never; Returns: string }
      _postgis_scripts_pgsql_version: { Args: never; Returns: string }
      _postgis_selectivity: {
        Args: { att_name: string; geom: unknown; mode?: string; tbl: unknown }
        Returns: number
      }
      _postgis_stats: {
        Args: { ""?: string; att_name: string; tbl: unknown }
        Returns: string
      }
      _st_3dintersects: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_contains: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_containsproperly: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_coveredby:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      _st_covers:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      _st_crosses: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_dwithin: {
        Args: {
          geog1: unknown
          geog2: unknown
          tolerance: number
          use_spheroid?: boolean
        }
        Returns: boolean
      }
      _st_equals: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      _st_intersects: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_linecrossingdirection: {
        Args: { line1: unknown; line2: unknown }
        Returns: number
      }
      _st_longestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      _st_maxdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      _st_orderingequals: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_overlaps: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_sortablehash: { Args: { geom: unknown }; Returns: number }
      _st_touches: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_voronoi: {
        Args: {
          clip?: unknown
          g1: unknown
          return_polygons?: boolean
          tolerance?: number
        }
        Returns: unknown
      }
      _st_within: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      addauth: { Args: { "": string }; Returns: boolean }
      addgeometrycolumn:
        | {
            Args: {
              catalog_name: string
              column_name: string
              new_dim: number
              new_srid_in: number
              new_type: string
              schema_name: string
              table_name: string
              use_typmod?: boolean
            }
            Returns: string
          }
        | {
            Args: {
              column_name: string
              new_dim: number
              new_srid: number
              new_type: string
              schema_name: string
              table_name: string
              use_typmod?: boolean
            }
            Returns: string
          }
        | {
            Args: {
              column_name: string
              new_dim: number
              new_srid: number
              new_type: string
              table_name: string
              use_typmod?: boolean
            }
            Returns: string
          }
      award_trip_xp: {
        Args: {
          p_base_xp: number
          p_trip_id: string
          p_trip_start: string
          p_user_id: string
        }
        Returns: {
          base_xp: number
          bonus_xp: number
          created_at: string
          id: string
          meta: Json | null
          multiplier: number
          source: string
          total_xp: number
          trip_id: string | null
          user_id: string
        }
        SetofOptions: {
          from: "*"
          to: "xp_events"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      cancel_join_request: {
        Args: { p_request_id: string }
        Returns: undefined
      }
      complete_trip_v2: { Args: { p_trip_id: string }; Returns: undefined }
      create_junior_invite_code: {
        Args: never
        Returns: {
          code: string
          created_at: string
          expires_at: string
          id: string
          is_used: boolean
          parent_id: string
          run_id: string
        }
        SetofOptions: {
          from: "*"
          to: "junior_invite_codes"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      create_run_grant_and_assign_driver: {
        Args: {
          p_driver_id: string
          p_ends_at: string
          p_run_id: string
          p_starts_at: string
        }
        Returns: {
          created_at: string
          driver_id: string
          ends_at: string
          id: string
          is_active: boolean
          kid_id: string | null
          parent_id: string
          run_id: string | null
          starts_at: string
        }
        SetofOptions: {
          from: "*"
          to: "junior_driver_grants"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      create_sos: {
        Args: {
          p_kind?: string
          p_lat: number
          p_lng: number
          p_message?: string
          p_meta?: Json
          p_run_id?: string
          p_severity?: number
          p_trip_id?: string
        }
        Returns: {
          created_at: string
          driver_id: string | null
          id: string
          kind: string
          lat: number
          lng: number
          message: string | null
          meta: Json | null
          parent_id: string | null
          run_id: string | null
          severity: number
          status: string
          triggered_by: string
          trip_id: string | null
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "sos_events"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      disablelongtransactions: { Args: never; Returns: string }
      driver_accept_request: {
        Args: { p_request_id: string }
        Returns: {
          created_at: string
          driver_id: string | null
          id: string
          passenger_id: string
          pickup_label: string | null
          pickup_lat: number | null
          pickup_lng: number | null
          status: string
          trip_id: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "trip_requests"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      driver_decline_request: {
        Args: { p_request_id: string }
        Returns: {
          created_at: string
          driver_id: string | null
          id: string
          passenger_id: string
          pickup_label: string | null
          pickup_lat: number | null
          pickup_lng: number | null
          status: string
          trip_id: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "trip_requests"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      dropgeometrycolumn:
        | {
            Args: {
              catalog_name: string
              column_name: string
              schema_name: string
              table_name: string
            }
            Returns: string
          }
        | {
            Args: {
              column_name: string
              schema_name: string
              table_name: string
            }
            Returns: string
          }
        | { Args: { column_name: string; table_name: string }; Returns: string }
      dropgeometrytable:
        | {
            Args: {
              catalog_name: string
              schema_name: string
              table_name: string
            }
            Returns: string
          }
        | { Args: { schema_name: string; table_name: string }; Returns: string }
        | { Args: { table_name: string }; Returns: string }
      enablelongtransactions: { Args: never; Returns: string }
      equals: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      geometry: { Args: { "": string }; Returns: unknown }
      geometry_above: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_below: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_cmp: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      geometry_contained_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_contains: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_contains_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_distance_box: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      geometry_distance_centroid: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      geometry_eq: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_ge: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_gt: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_le: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_left: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_lt: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overabove: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overbelow: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overlaps: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overlaps_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overleft: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overright: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_right: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_same: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_same_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_within: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geomfromewkt: { Args: { "": string }; Returns: unknown }
      gettransactionid: { Args: never; Returns: unknown }
      has_active_grant_for_kid: { Args: { p_kid_id: string }; Returns: boolean }
      has_active_grant_for_run: { Args: { p_run_id: string }; Returns: boolean }
      is_run_driver_with_grant: { Args: { p_run_id: string }; Returns: boolean }
      is_run_parent: { Args: { p_run_id: string }; Returns: boolean }
      is_run_party: { Args: { p_run_id: string }; Returns: boolean }
      is_trip_driver: { Args: { p_trip_id: string }; Returns: boolean }
      is_trip_participant: { Args: { p_trip_id: string }; Returns: boolean }
      longtransactionsenabled: { Args: never; Returns: boolean }
      me_profile: {
        Args: never
        Returns: {
          gender: string
          id: string
          neighborhood_id: string
        }[]
      }
      populate_geometry_columns:
        | { Args: { tbl_oid: unknown; use_typmod?: boolean }; Returns: number }
        | { Args: { use_typmod?: boolean }; Returns: string }
      postgis_constraint_dims: {
        Args: { geomcolumn: string; geomschema: string; geomtable: string }
        Returns: number
      }
      postgis_constraint_srid: {
        Args: { geomcolumn: string; geomschema: string; geomtable: string }
        Returns: number
      }
      postgis_constraint_type: {
        Args: { geomcolumn: string; geomschema: string; geomtable: string }
        Returns: string
      }
      postgis_extensions_upgrade: { Args: never; Returns: string }
      postgis_full_version: { Args: never; Returns: string }
      postgis_geos_version: { Args: never; Returns: string }
      postgis_lib_build_date: { Args: never; Returns: string }
      postgis_lib_revision: { Args: never; Returns: string }
      postgis_lib_version: { Args: never; Returns: string }
      postgis_libjson_version: { Args: never; Returns: string }
      postgis_liblwgeom_version: { Args: never; Returns: string }
      postgis_libprotobuf_version: { Args: never; Returns: string }
      postgis_libxml_version: { Args: never; Returns: string }
      postgis_proj_version: { Args: never; Returns: string }
      postgis_scripts_build_date: { Args: never; Returns: string }
      postgis_scripts_installed: { Args: never; Returns: string }
      postgis_scripts_released: { Args: never; Returns: string }
      postgis_svn_version: { Args: never; Returns: string }
      postgis_type_name: {
        Args: {
          coord_dimension: number
          geomname: string
          use_new_name?: boolean
        }
        Returns: string
      }
      postgis_version: { Args: never; Returns: string }
      postgis_wagyu_version: { Args: never; Returns: string }
      rating_funnel_summary: {
        Args: { p_days?: number }
        Returns: {
          role: string
          submit_fail_rate_pct: number
          submit_failed: number
          submit_rate_pct: number
          submitted: number
          targets_missing: number
          targets_resolved: number
        }[]
      }
      redeem_junior_invite_code: { Args: { p_code: string }; Returns: boolean }
      revoke_driver_grant: { Args: { p_grant_id: string }; Returns: undefined }
      send_join_request:
        | {
            Args: { p_trip_id: string }
            Returns: {
              created_at: string
              driver_id: string | null
              id: string
              passenger_id: string
              pickup_label: string | null
              pickup_lat: number | null
              pickup_lng: number | null
              status: string
              trip_id: string
              updated_at: string
            }
            SetofOptions: {
              from: "*"
              to: "trip_requests"
              isOneToOne: true
              isSetofReturn: false
            }
          }
        | {
            Args: {
              p_pickup_label?: string
              p_pickup_lat?: number
              p_pickup_lng?: number
              p_trip_id: string
            }
            Returns: Json
          }
      st_3dclosestpoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_3ddistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_3dintersects: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_3dlongestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_3dmakebox: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_3dmaxdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_3dshortestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_addpoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_angle:
        | { Args: { line1: unknown; line2: unknown }; Returns: number }
        | {
            Args: { pt1: unknown; pt2: unknown; pt3: unknown; pt4?: unknown }
            Returns: number
          }
      st_area:
        | { Args: { geog: unknown; use_spheroid?: boolean }; Returns: number }
        | { Args: { "": string }; Returns: number }
      st_asencodedpolyline: {
        Args: { geom: unknown; nprecision?: number }
        Returns: string
      }
      st_asewkt: { Args: { "": string }; Returns: string }
      st_asgeojson:
        | {
            Args: { geog: unknown; maxdecimaldigits?: number; options?: number }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; options?: number }
            Returns: string
          }
        | {
            Args: {
              geom_column?: string
              maxdecimaldigits?: number
              pretty_bool?: boolean
              r: Record<string, unknown>
            }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
      st_asgml:
        | {
            Args: {
              geog: unknown
              id?: string
              maxdecimaldigits?: number
              nprefix?: string
              options?: number
            }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; options?: number }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
        | {
            Args: {
              geog: unknown
              id?: string
              maxdecimaldigits?: number
              nprefix?: string
              options?: number
              version: number
            }
            Returns: string
          }
        | {
            Args: {
              geom: unknown
              id?: string
              maxdecimaldigits?: number
              nprefix?: string
              options?: number
              version: number
            }
            Returns: string
          }
      st_askml:
        | {
            Args: { geog: unknown; maxdecimaldigits?: number; nprefix?: string }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; nprefix?: string }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
      st_aslatlontext: {
        Args: { geom: unknown; tmpl?: string }
        Returns: string
      }
      st_asmarc21: { Args: { format?: string; geom: unknown }; Returns: string }
      st_asmvtgeom: {
        Args: {
          bounds: unknown
          buffer?: number
          clip_geom?: boolean
          extent?: number
          geom: unknown
        }
        Returns: unknown
      }
      st_assvg:
        | {
            Args: { geog: unknown; maxdecimaldigits?: number; rel?: number }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; rel?: number }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
      st_astext: { Args: { "": string }; Returns: string }
      st_astwkb:
        | {
            Args: {
              geom: unknown
              prec?: number
              prec_m?: number
              prec_z?: number
              with_boxes?: boolean
              with_sizes?: boolean
            }
            Returns: string
          }
        | {
            Args: {
              geom: unknown[]
              ids: number[]
              prec?: number
              prec_m?: number
              prec_z?: number
              with_boxes?: boolean
              with_sizes?: boolean
            }
            Returns: string
          }
      st_asx3d: {
        Args: { geom: unknown; maxdecimaldigits?: number; options?: number }
        Returns: string
      }
      st_azimuth:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: number }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: number }
      st_boundingdiagonal: {
        Args: { fits?: boolean; geom: unknown }
        Returns: unknown
      }
      st_buffer:
        | {
            Args: { geom: unknown; options?: string; radius: number }
            Returns: unknown
          }
        | {
            Args: { geom: unknown; quadsegs: number; radius: number }
            Returns: unknown
          }
      st_centroid: { Args: { "": string }; Returns: unknown }
      st_clipbybox2d: {
        Args: { box: unknown; geom: unknown }
        Returns: unknown
      }
      st_closestpoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_collect: { Args: { geom1: unknown; geom2: unknown }; Returns: unknown }
      st_concavehull: {
        Args: {
          param_allow_holes?: boolean
          param_geom: unknown
          param_pctconvex: number
        }
        Returns: unknown
      }
      st_contains: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_containsproperly: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_coorddim: { Args: { geometry: unknown }; Returns: number }
      st_coveredby:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_covers:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_crosses: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_curvetoline: {
        Args: { flags?: number; geom: unknown; tol?: number; toltype?: number }
        Returns: unknown
      }
      st_delaunaytriangles: {
        Args: { flags?: number; g1: unknown; tolerance?: number }
        Returns: unknown
      }
      st_difference: {
        Args: { geom1: unknown; geom2: unknown; gridsize?: number }
        Returns: unknown
      }
      st_disjoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_distance:
        | {
            Args: { geog1: unknown; geog2: unknown; use_spheroid?: boolean }
            Returns: number
          }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: number }
      st_distancesphere:
        | { Args: { geom1: unknown; geom2: unknown }; Returns: number }
        | {
            Args: { geom1: unknown; geom2: unknown; radius: number }
            Returns: number
          }
      st_distancespheroid: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_dwithin: {
        Args: {
          geog1: unknown
          geog2: unknown
          tolerance: number
          use_spheroid?: boolean
        }
        Returns: boolean
      }
      st_equals: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_expand:
        | { Args: { box: unknown; dx: number; dy: number }; Returns: unknown }
        | {
            Args: { box: unknown; dx: number; dy: number; dz?: number }
            Returns: unknown
          }
        | {
            Args: {
              dm?: number
              dx: number
              dy: number
              dz?: number
              geom: unknown
            }
            Returns: unknown
          }
      st_force3d: { Args: { geom: unknown; zvalue?: number }; Returns: unknown }
      st_force3dm: {
        Args: { geom: unknown; mvalue?: number }
        Returns: unknown
      }
      st_force3dz: {
        Args: { geom: unknown; zvalue?: number }
        Returns: unknown
      }
      st_force4d: {
        Args: { geom: unknown; mvalue?: number; zvalue?: number }
        Returns: unknown
      }
      st_generatepoints:
        | { Args: { area: unknown; npoints: number }; Returns: unknown }
        | {
            Args: { area: unknown; npoints: number; seed: number }
            Returns: unknown
          }
      st_geogfromtext: { Args: { "": string }; Returns: unknown }
      st_geographyfromtext: { Args: { "": string }; Returns: unknown }
      st_geohash:
        | { Args: { geog: unknown; maxchars?: number }; Returns: string }
        | { Args: { geom: unknown; maxchars?: number }; Returns: string }
      st_geomcollfromtext: { Args: { "": string }; Returns: unknown }
      st_geometricmedian: {
        Args: {
          fail_if_not_converged?: boolean
          g: unknown
          max_iter?: number
          tolerance?: number
        }
        Returns: unknown
      }
      st_geometryfromtext: { Args: { "": string }; Returns: unknown }
      st_geomfromewkt: { Args: { "": string }; Returns: unknown }
      st_geomfromgeojson:
        | { Args: { "": Json }; Returns: unknown }
        | { Args: { "": Json }; Returns: unknown }
        | { Args: { "": string }; Returns: unknown }
      st_geomfromgml: { Args: { "": string }; Returns: unknown }
      st_geomfromkml: { Args: { "": string }; Returns: unknown }
      st_geomfrommarc21: { Args: { marc21xml: string }; Returns: unknown }
      st_geomfromtext: { Args: { "": string }; Returns: unknown }
      st_gmltosql: { Args: { "": string }; Returns: unknown }
      st_hasarc: { Args: { geometry: unknown }; Returns: boolean }
      st_hausdorffdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_hexagon: {
        Args: { cell_i: number; cell_j: number; origin?: unknown; size: number }
        Returns: unknown
      }
      st_hexagongrid: {
        Args: { bounds: unknown; size: number }
        Returns: Record<string, unknown>[]
      }
      st_interpolatepoint: {
        Args: { line: unknown; point: unknown }
        Returns: number
      }
      st_intersection: {
        Args: { geom1: unknown; geom2: unknown; gridsize?: number }
        Returns: unknown
      }
      st_intersects:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_isvaliddetail: {
        Args: { flags?: number; geom: unknown }
        Returns: Database["public"]["CompositeTypes"]["valid_detail"]
        SetofOptions: {
          from: "*"
          to: "valid_detail"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      st_length:
        | { Args: { geog: unknown; use_spheroid?: boolean }; Returns: number }
        | { Args: { "": string }; Returns: number }
      st_letters: { Args: { font?: Json; letters: string }; Returns: unknown }
      st_linecrossingdirection: {
        Args: { line1: unknown; line2: unknown }
        Returns: number
      }
      st_linefromencodedpolyline: {
        Args: { nprecision?: number; txtin: string }
        Returns: unknown
      }
      st_linefromtext: { Args: { "": string }; Returns: unknown }
      st_linelocatepoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_linetocurve: { Args: { geometry: unknown }; Returns: unknown }
      st_locatealong: {
        Args: { geometry: unknown; leftrightoffset?: number; measure: number }
        Returns: unknown
      }
      st_locatebetween: {
        Args: {
          frommeasure: number
          geometry: unknown
          leftrightoffset?: number
          tomeasure: number
        }
        Returns: unknown
      }
      st_locatebetweenelevations: {
        Args: { fromelevation: number; geometry: unknown; toelevation: number }
        Returns: unknown
      }
      st_longestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_makebox2d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_makeline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_makevalid: {
        Args: { geom: unknown; params: string }
        Returns: unknown
      }
      st_maxdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_minimumboundingcircle: {
        Args: { inputgeom: unknown; segs_per_quarter?: number }
        Returns: unknown
      }
      st_mlinefromtext: { Args: { "": string }; Returns: unknown }
      st_mpointfromtext: { Args: { "": string }; Returns: unknown }
      st_mpolyfromtext: { Args: { "": string }; Returns: unknown }
      st_multilinestringfromtext: { Args: { "": string }; Returns: unknown }
      st_multipointfromtext: { Args: { "": string }; Returns: unknown }
      st_multipolygonfromtext: { Args: { "": string }; Returns: unknown }
      st_node: { Args: { g: unknown }; Returns: unknown }
      st_normalize: { Args: { geom: unknown }; Returns: unknown }
      st_offsetcurve: {
        Args: { distance: number; line: unknown; params?: string }
        Returns: unknown
      }
      st_orderingequals: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_overlaps: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_perimeter: {
        Args: { geog: unknown; use_spheroid?: boolean }
        Returns: number
      }
      st_pointfromtext: { Args: { "": string }; Returns: unknown }
      st_pointm: {
        Args: {
          mcoordinate: number
          srid?: number
          xcoordinate: number
          ycoordinate: number
        }
        Returns: unknown
      }
      st_pointz: {
        Args: {
          srid?: number
          xcoordinate: number
          ycoordinate: number
          zcoordinate: number
        }
        Returns: unknown
      }
      st_pointzm: {
        Args: {
          mcoordinate: number
          srid?: number
          xcoordinate: number
          ycoordinate: number
          zcoordinate: number
        }
        Returns: unknown
      }
      st_polyfromtext: { Args: { "": string }; Returns: unknown }
      st_polygonfromtext: { Args: { "": string }; Returns: unknown }
      st_project: {
        Args: { azimuth: number; distance: number; geog: unknown }
        Returns: unknown
      }
      st_quantizecoordinates: {
        Args: {
          g: unknown
          prec_m?: number
          prec_x: number
          prec_y?: number
          prec_z?: number
        }
        Returns: unknown
      }
      st_reduceprecision: {
        Args: { geom: unknown; gridsize: number }
        Returns: unknown
      }
      st_relate: { Args: { geom1: unknown; geom2: unknown }; Returns: string }
      st_removerepeatedpoints: {
        Args: { geom: unknown; tolerance?: number }
        Returns: unknown
      }
      st_segmentize: {
        Args: { geog: unknown; max_segment_length: number }
        Returns: unknown
      }
      st_setsrid:
        | { Args: { geog: unknown; srid: number }; Returns: unknown }
        | { Args: { geom: unknown; srid: number }; Returns: unknown }
      st_sharedpaths: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_shortestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_simplifypolygonhull: {
        Args: { geom: unknown; is_outer?: boolean; vertex_fraction: number }
        Returns: unknown
      }
      st_split: { Args: { geom1: unknown; geom2: unknown }; Returns: unknown }
      st_square: {
        Args: { cell_i: number; cell_j: number; origin?: unknown; size: number }
        Returns: unknown
      }
      st_squaregrid: {
        Args: { bounds: unknown; size: number }
        Returns: Record<string, unknown>[]
      }
      st_srid:
        | { Args: { geog: unknown }; Returns: number }
        | { Args: { geom: unknown }; Returns: number }
      st_subdivide: {
        Args: { geom: unknown; gridsize?: number; maxvertices?: number }
        Returns: unknown[]
      }
      st_swapordinates: {
        Args: { geom: unknown; ords: unknown }
        Returns: unknown
      }
      st_symdifference: {
        Args: { geom1: unknown; geom2: unknown; gridsize?: number }
        Returns: unknown
      }
      st_symmetricdifference: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_tileenvelope: {
        Args: {
          bounds?: unknown
          margin?: number
          x: number
          y: number
          zoom: number
        }
        Returns: unknown
      }
      st_touches: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_transform:
        | {
            Args: { from_proj: string; geom: unknown; to_proj: string }
            Returns: unknown
          }
        | {
            Args: { from_proj: string; geom: unknown; to_srid: number }
            Returns: unknown
          }
        | { Args: { geom: unknown; to_proj: string }; Returns: unknown }
      st_triangulatepolygon: { Args: { g1: unknown }; Returns: unknown }
      st_union:
        | { Args: { geom1: unknown; geom2: unknown }; Returns: unknown }
        | {
            Args: { geom1: unknown; geom2: unknown; gridsize: number }
            Returns: unknown
          }
      st_voronoilines: {
        Args: { extend_to?: unknown; g1: unknown; tolerance?: number }
        Returns: unknown
      }
      st_voronoipolygons: {
        Args: { extend_to?: unknown; g1: unknown; tolerance?: number }
        Returns: unknown
      }
      st_within: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_wkbtosql: { Args: { wkb: string }; Returns: unknown }
      st_wkttosql: { Args: { "": string }; Returns: unknown }
      st_wrapx: {
        Args: { geom: unknown; move: number; wrap: number }
        Returns: unknown
      }
      submit_rating: {
        Args: {
          p_comment: string
          p_ratee_id: string
          p_stars: number
          p_tags: string[]
          p_trip_id: string
        }
        Returns: undefined
      }
      unlockrows: { Args: { "": string }; Returns: number }
      update_junior_run_status: {
        Args: {
          p_lat?: number
          p_lng?: number
          p_meta?: Json
          p_new_status: string
          p_run_id: string
        }
        Returns: {
          assigned_driver_id: string | null
          created_at: string
          dropoff_lat: number
          dropoff_lng: number
          id: string
          kid_id: string
          parent_id: string
          pickup_lat: number
          pickup_lng: number
          pickup_time: string
          status: string
          trip_id: string | null
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "junior_runs"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      update_sos_status: {
        Args: { p_sos_id: string; p_status: string }
        Returns: undefined
      }
      updategeometrysrid: {
        Args: {
          catalogn_name: string
          column_name: string
          new_srid_in: number
          schema_name: string
          table_name: string
        }
        Returns: string
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      geometry_dump: {
        path: number[] | null
        geom: unknown
      }
      valid_detail: {
        valid: boolean | null
        reason: string | null
        location: unknown
      }
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
