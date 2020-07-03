defmodule ChatApp.Msg do
  @moduledoc """
  The Msg context.
  """

  import Ecto.Query, warn: false
  alias ChatApp.Repo

  alias ChatApp.Msg.Group

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id) 

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  alias ChatApp.Msg.GroupUser

  @doc """
  Returns the list of groups_user.

  ## Examples

      iex> list_groups_user()
      [%GroupUser{}, ...]

  """
  def list_groups_user do
    Repo.all(GroupUser)
  end

  @doc """
  Gets a single group_user.

  Raises `Ecto.NoResultsError` if the Group user does not exist.

  ## Examples

      iex> get_group_user!(123)
      %GroupUser{}

      iex> get_group_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_user(group_id, user_id) do
    query = from gu in GroupUser, where: gu.group_id == ^group_id and gu.user_id == ^user_id
    query
    |> Repo.one()
  end

  @doc """
  Creates a group_user.

  ## Examples

      iex> create_group_user(%{field: value})
      {:ok, %GroupUser{}}

      iex> create_group_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_user(attrs \\ %{}) do
    %GroupUser{}
    |> GroupUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group_user.

  ## Examples

      iex> update_group_user(group_user, %{field: new_value})
      {:ok, %GroupUser{}}

      iex> update_group_user(group_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group_user(%GroupUser{} = group_user, attrs) do
    group_user
    |> GroupUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group_user.

  ## Examples

      iex> delete_group_user(group_user)
      {:ok, %GroupUser{}}

      iex> delete_group_user(group_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_user(%GroupUser{} = group_user) do
    Repo.delete(group_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group_user changes.

  ## Examples

      iex> change_group_user(group_user)
      %Ecto.Changeset{data: %GroupUser{}}

  """
  def change_group_user(%GroupUser{} = group_user, attrs \\ %{}) do
    GroupUser.changeset(group_user, attrs)
  end

  def is_member?(user_id, group_id) do
    query = from gu in GroupUser,
    where: gu.user_id == ^user_id and gu.group_id == ^group_id

    !!Repo.one(query)
  end

  def is_owner?(user_id, group_id) do
    query = from gu in GroupUser,
    where: gu.user_id == ^user_id and gu.group_id == type(^group_id, :integer) and gu.role == "owner"

    !!Repo.one(query)
  end

  def recent_messages("room:"<>group_id) do
    query = from m in ChatApp.Msg.Message, where: m.group_id == type(^group_id, :integer)

    query
    |> Repo.all()
    |> Repo.preload(:user)
  end
end
