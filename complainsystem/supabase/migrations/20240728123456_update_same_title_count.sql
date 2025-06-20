-- Create the function to update same_title_count
create
or replace function public.update_complaint_same_title_count () returns trigger as $$
declare
  complaint_title text;
  new_count int;
begin
  if TG_OP = 'INSERT' then
    complaint_title := NEW.title;
  elsif TG_OP = 'UPDATE' then
    complaint_title := NEW.title;
  else
    complaint_title := OLD.title;
  end if;

  -- Recalculate the count for the given title
  select count(*) into new_count
  from public.complaints
  where title = complaint_title
    and status not in ('Resolved', 'Rejected');

  -- Update all relevant complaints
  update public.complaints
  set same_title_count = new_count
  where title = complaint_title;

  if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then
    return NEW;
  else
    return OLD;
  end if;
end;
$$ language plpgsql security definer;

-- Create the trigger to fire the function
create trigger on_complaint_change
after insert
or delete
or update of status, title on public.complaints for each row
execute function public.update_complaint_same_title_count (); 