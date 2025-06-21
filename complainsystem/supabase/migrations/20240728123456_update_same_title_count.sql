-- Drop the old trigger and function to ensure a clean slate
drop trigger if exists on_complaint_change on public.complaints;
drop function if exists public.update_complaint_same_title_count();

-- Create the corrected function
create or replace function public.update_complaint_same_title_count()
returns trigger as $$
declare
  complaint_title text;
  new_count int;
begin
  -- Use a session-level advisory lock to prevent recursion.
  -- The lock is based on the hash of the function name.
  if pg_try_advisory_xact_lock(hashtext('update_complaint_same_title_count')) then
    if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then
      complaint_title := NEW.title;
    else -- TG_OP = 'DELETE'
      complaint_title := OLD.title;
    end if;

    -- Recalculate the count for the given title
    select count(*) into new_count
    from public.complaints
    where title = complaint_title
      and status not in ('Resolved', 'Rejected');

    -- Update all relevant complaints with the new count
    update public.complaints
    set same_title_count = new_count
    where title = complaint_title;
  end if;

  if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then
    return NEW;
  else
    return OLD;
  end if;
end;
$$ language plpgsql security definer;

-- Create the trigger to fire the function
create trigger on_complaint_change
after insert or delete or update of status, title on public.complaints
for each row
execute function public.update_complaint_same_title_count(); 