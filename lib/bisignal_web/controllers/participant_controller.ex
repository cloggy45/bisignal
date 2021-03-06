defmodule BisignalWeb.ParticipantController do
  use BisignalWeb, :controller
  import BisignalWeb.Authorize
  alias Bisignal.Ride
  alias Bisignal.Ride.Participant

  plug :user_check when action in [:create, :delete, :show_by_user]
  plug :user_id_check when action in [:show_by_user, :show]


  def show_by_user(conn, %{"user_id" => id}) do
    route_details = Ride.get_participation_by_user(id)
    render(conn, "index.html", route_details: route_details)
  end

  def show(conn, %{"user_id" => user_id, "id" => id}) do
    case Ride.get_participant_by_route_and_user(user_id, id) do
      [] ->
        conn 
        |> put_flash(:info, "Participation not found!")
        |> redirect(to: user_participant_path(conn, :show_by_user, user_id))
      [participant] ->
        conn
        |> put_flash(:info, "Ready to Broadcast")
        |> render("show.html", participant: participant)
    end
  end

  # def new(conn, _params) do
  #   changeset = Ride.change_participant(%Participant{})
  #   render(conn, "new.html", changeset: changeset)
  # end
 
  def create(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user.id
    participant = %{"user_id" => current_user, "route_id" => id}
    case Ride.create_participant(participant) do
      {:ok, participant} ->
        conn
        |> put_flash(:info, "You're now a participant of this ride.")
        |> redirect(to: route_detail_path(conn, :show, id))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn 
        |> put_flash(:info, "You're already subscribed!")
        |> redirect(to: route_detail_path(conn, :show, id))
    end
  end

  # def show(conn, %{"id" => id}) do
  #   participant = Ride.get_participant!(id)
  #   render(conn, "show.html", participant: participant)
  # end

  # def edit(conn, %{"id" => id}) do
  #   participant = Ride.get_participant!(id)
  #   changeset = Ride.change_participant(participant)
  #   render(conn, "edit.html", participant: participant, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "participant" => participant_params}) do
  #   participant = Ride.get_participant!(id)

  #   case Ride.update_participant(participant, participant_params) do
  #     {:ok, participant} ->
  #       conn
  #       |> put_flash(:info, "Participant updated successfully.")
  #       |> redirect(to: participant_path(conn, :show, participant))
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", participant: participant, changeset: changeset)
  #   end
  # end

  def delete(conn, %{"id" => route_id}) do
    current_user = conn.assigns.current_user.id
    case Ride.get_participant_by_route_and_user(current_user, route_id) do
      [] ->
        conn 
        |> put_flash(:info, "You weren't subscribed!")
        |> redirect(to: route_detail_path(conn, :show, route_id))
      [record] ->
        Ride.delete_participant(record)
        conn
        |> put_flash(:info, "You're no longer a participant in this Ride.")
        |> redirect(to: route_detail_path(conn, :show, route_id))
    end
  end
end
