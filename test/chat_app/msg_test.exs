defmodule ChatApp.MsgTest do
  use ChatApp.DataCase

  alias ChatApp.Msg

  describe "groups" do
    alias ChatApp.Msg.Group

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def group_fixture(attrs \\ %{}) do
      {:ok, group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Msg.create_group()

      group
    end

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Msg.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Msg.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      assert {:ok, %Group{} = group} = Msg.create_group(@valid_attrs)
      assert group.name == "some name"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Msg.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      assert {:ok, %Group{} = group} = Msg.update_group(group, @update_attrs)
      assert group.name == "some updated name"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Msg.update_group(group, @invalid_attrs)
      assert group == Msg.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Msg.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Msg.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Msg.change_group(group)
    end
  end

  describe "groups_user" do
    alias ChatApp.Msg.GroupUser

    @valid_attrs %{role: "some role"}
    @update_attrs %{role: "some updated role"}
    @invalid_attrs %{role: nil}

    def group_user_fixture(attrs \\ %{}) do
      {:ok, group_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Msg.create_group_user()

      group_user
    end

    test "list_groups_user/0 returns all groups_user" do
      group_user = group_user_fixture()
      assert Msg.list_groups_user() == [group_user]
    end

    test "get_group_user!/1 returns the group_user with given id" do
      group_user = group_user_fixture()
      assert Msg.get_group_user!(group_user.id) == group_user
    end

    test "create_group_user/1 with valid data creates a group_user" do
      assert {:ok, %GroupUser{} = group_user} = Msg.create_group_user(@valid_attrs)
      assert group_user.role == "some role"
    end

    test "create_group_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Msg.create_group_user(@invalid_attrs)
    end

    test "update_group_user/2 with valid data updates the group_user" do
      group_user = group_user_fixture()
      assert {:ok, %GroupUser{} = group_user} = Msg.update_group_user(group_user, @update_attrs)
      assert group_user.role == "some updated role"
    end

    test "update_group_user/2 with invalid data returns error changeset" do
      group_user = group_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Msg.update_group_user(group_user, @invalid_attrs)
      assert group_user == Msg.get_group_user!(group_user.id)
    end

    test "delete_group_user/1 deletes the group_user" do
      group_user = group_user_fixture()
      assert {:ok, %GroupUser{}} = Msg.delete_group_user(group_user)
      assert_raise Ecto.NoResultsError, fn -> Msg.get_group_user!(group_user.id) end
    end

    test "change_group_user/1 returns a group_user changeset" do
      group_user = group_user_fixture()
      assert %Ecto.Changeset{} = Msg.change_group_user(group_user)
    end
  end
end
