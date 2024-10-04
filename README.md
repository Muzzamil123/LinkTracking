# Ruby on Rails Assignment: Implement Link Click Tracking

## Overview

Your task is to implement a feature in this Rails 8 application that tracks every link click, both to internal pages and external websites.
This data should be stored in a database table called `link_clicks` without significantly impacting the application's performance.

### Technical Requirements

- Ruby 3.3.5
- Rails 8.0.0.beta1
- SQLite
- Solid Queue for background jobs
- Solid Cache for caching

### Core Features

1. Track clicks on all links within the application
2. Store click data in the `link_clicks` table
3. Capture relevant details about each click
4. Implement the feature with minimal performance impact

### Implementation Details
- I've added a `LinkClick` model with necessary validations and also indexes to fetch data faster.
- I've used `@hotwired/stimulus` **LinkClickController** in **js** which is initialized under 
  `application.html.erb's <main> tag i.e data-controller="link-click"` which is responsible for tracking all links 
  across website. I am using **navigator.sendBeacon** to send click links asynchronously but also using fallback approach
  in case browser doesn't support **sendBeacon**. On top of that I am also using **Debouncing mechanism** to only
  send request if user doesn't click on any link for 4 seconds just to avoid overloading server. I am sending clicks in
  batches if user clicks multiple times within _4 secs_ (this we can change in js file). Also sending batch unsent clicks on `page_unload` event.
- I've used `SolidQueue` for background processing which will perform **StoreLinkClickJob** asynchronously to create `LinkClick` records.
- For **Rate Limiting**, I used **Rails 8's** smart mechanism instead of using an external gem where we can define **RateLimit** for
  specific action, you can see this under **LinkClicksController**.
- For Admin's Dashboard Stats, I introduced **Concern** named **LinkClickAnalytics** which is responsible for
  calculating all **LinkClick Stats**. I used Rails cache mechanism (**solid_cache in specific**) to keep stats in cache
  for **5 minutes** before making new query (Also this value can be changed as per needs under concern). Also verified
  using **.explain** that all stats queries are using index scan.
- I used **Tailwind** to design and display Admin's dashboard stats.
- For **specs**, I've used **minitest** and wrote `model`, `concern`, `job` and `controller integration's` tests. 

### Commands to setup and start project from scratch

1. Add `queue`,`cache` and `primary` section under `development` in `database.yml` (if you don't have it)
2. Execute these commands:
   - `bin/rails db:drop` (only if databases exists previously under `storage/` path)
   - `bin/rails solid_queue:install`
   - `bin/rails solid_cache:install` (you need to add `database: cache` under each env in `config/cache.yml` file)
   - `bin/rails db:prepare`
   - `bin/rails db:migrate`
   - `bin/rails solid_queue:start` (in a separate terminal for background job)
   - you can start `server` using `./bin/dev` under project directory (tailwind styling will appear automatically as well)

